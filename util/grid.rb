#!/usr/bin/env ruby

class Grid
  attr_accessor :grid
  attr_reader :width
  attr_reader :height
  attr_reader :default

  def initialize(input, default: nil)
    @grid = input.lines
              .map(&:strip)
              .map(&:chars)
    @width = @grid[0].size
    @height = @grid.size
    @default = default
  end

  def in_bounds?(x, y)
    x >= 0 && x < @width && y >= 0 && y < @height
  end

  def get(x,y)
    if x < 0 || x >= @width || y < 0 || y >= @height
      @default
    else
      @grid[y][x]
    end
  end

  def set(x,y,val)
    if x < 0 || x >= @width || y < 0 || y >= @height
      raise "Tried to write out of bounds"
    else
      @grid[y][x] = val
    end
  end

  def all_coords
    (0...width).to_a.product((0...height).to_a)
  end

  def coords_where
    all_coords.filter { |x, y| yield(@grid[y][x]) }
  end

  def each_index
    height.times do |y|
      width.times do |x|
        yield(x,y)
      end
    end
  end

  def update
    each_index do |x, y|
      @grid[y][x] = yield(x, y, @grid[y][x])
    end
  end

  def ==(other)
    return false if other.class != Grid
    return other.grid == @grid
  end

  def all?(value)
    return @grid.flatten.all?(value)
  end

  def neighbors(x,y)
    [
      [-1, -1], [0, -1], [+1, -1],
      [-1,  0],          [+1, 0],
      [-1, +1], [0, +1], [+1, +1]
    ].map { |dx, dy| get(x+dx, y+dy) }
  end

  def to_s
    s = ""
    height.times do |y|
      width.times do |x|
        s << get(x,y) || default.to_s
      end
      s << "\n"
    end
    return s
  end

  def count(value)
    if block_given?
      @grid.flatten.count(&block)
    else
      @grid.flatten.count(value)
    end
  end
end

class Grid4d
  attr_accessor :grid
  attr_accessor :size
  def initialize(input, size, default: '.')
    @default = default
    @size = size
    @min_w, @max_w = -size, size
    @min_y, @max_y = -size, size
    @min_x, @max_x = -size, size
    @min_z, @max_z = -size, size
    @grid = Array.new(size*size*size*size)

    lines = input.lines
              .map(&:strip)
              .map(&:chars)
    lines.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        @grid[coords_to_idx(x,y,0,0)]=cell
      end
    end
  end

  def coords_to_idx(x,y,z,w)
    x_offset = x * size * size * size
    y_offset = y * size * size
    z_offset = z * size
    w_offset = w
    x_offset + y_offset + z_offset + w_offset
  end

  def get(x,y,z,w)
    idx = coords_to_idx(x,y,z,w)
    if idx > @grid.size || idx < 0
      @default
    else
      @grid[idx]
    end
  end

  def set(x,y,z,w,value)
    idx = coords_to_idx(x,y,z,w)
    if idx > @grid.size || idx < 0
      #raise "tried to write out of bounds: #{[x,y,z,w]}"
    else
      @grid[idx] = value
    end
  end

  def neighbors4d(x,y,z,w)
    xs = [x-1, x, x+1]
    ys = [y-1, y, y+1]
    zs = [z-1, z, z+1]
    ws = [w-1, w, w+1]
    xs.product(ys)
      .product(zs)
      .product(ws)
      .map(&:flatten)
      .map { |dx, dy, dz, dw| get(x+dx, y+dy, z+dz, w+dw) }
  end

  def count(val)
    @grid.count(val)
  end

  def each_index
    (@min_w...@max_w).each do |w|
      (@min_z...@max_z).each do |z|
        (@min_x...@max_x).each do |x|
          (@min_y...@max_y).each do |y|
            yield [x,y,z,w]
          end
        end
      end
    end
  end

end

class HashGrid < Grid
  attr_accessor :grid

  def initialize(input, default: nil)
    @grid = Hash.new(default)
    lines = input.lines
              .map(&:strip)
              .map(&:chars)
    lines.each_with_index do |row, y|
      row.each_with_index do |cell, x|
        @grid[[x,y,0,0]] = cell
      end
    end
    @min_x = 0
    @min_y = 0
    @min_z = 0
    @min_w = 0
    @max_x = lines.first.size-1
    @max_y = lines.size-1
    @max_z = 0
    @max_w = 0
  end

  def get(x,y,z=0,w=0)
    @grid[[x,y,z,w]]
  end

  def set(x,y,z,w,val)
    @min_x = x if x < @min_x
    @min_y = y if y < @min_y
    @min_z = z if z < @min_z
    @min_w = w if w < @min_w
    @max_x = x if x > @max_x
    @max_y = y if y > @max_y
    @max_z = z if z > @max_z
    @max_w = w if w > @max_w

    @grid[[x,y,z,w]] = val
  end

  # def set(x,y,val)
  #   set(x,y,0,val)
  # end

  def depth
    (@max_z - @min_z) +1
  end

  def width
    (@max_x - @min_x) +1
  end

  def height
    (@max_y - @min_y) +1
  end

  def size_w
    (@max_w - @min_w) + 1
  end

  def to_s
    s = ""
    depth.times do |i|
      z = @min_z + i
      s << "z=#{z.to_s}:\n"
      height.times do |y|
        width.times do |x|
          s << get(@min_x + x, @min_y + y, z) || default.to_s
        end
        s << "\n"
      end
      s << "\n"
    end
    return s
  end

  def neighbors4d(x,y,z,w)
    xs = [x-1, x, x+1]
    ys = [y-1, y, y+1]
    zs = [z-1, z, z+1]
    ws = [w-1, w, w+1]
    xs.product(ys)
      .product(zs)
      .product(ws)
      .map(&:flatten)
      .map { |dx, dy, dz, dw| get(x+dx, y+dy, z+dz, w+dw) }
  end

  def neighbors3d(x,y,z)
    [
      [-1, -1, -1], [0, -1, -1], [+1, -1, -1],
      [-1,  0, -1], [0,  0, -1], [+1,  0, -1],
      [-1, +1, -1], [0, +1, -1], [+1, +1, -1],

      [-1, -1, 0], [0, -1,  0], [+1, -1, 0],
      [-1,  0, 0],              [+1,  0, 0],
      [-1, +1, 0], [0, +1,  0], [+1, +1, 0],

      [-1, -1, +1], [0, -1, +1], [+1, -1, +1],
      [-1,  0, +1], [0,  0, +1], [+1,  0, +1],
      [-1, +1, +1], [0, +1, +1], [+1, +1, +1],
    ].map { |dx, dy, dz| get(x+dx, y+dy, z+dz) }
  end

  def each_index
    (@min_w..@max_w).each do |w|
      (@min_z..@max_z).each do |z|
        (@min_x..@max_x).each do |x|
          (@min_y..@max_y).each do |y|
            yield [x,y,z,w]
          end
        end
      end
    end
  end

  def count(value)
    @grid.values.count(value)
  end

  def ==(other)
    return false if other.class != HashGrid
    each_index do |x,y,z|
      return false unless get(x,y,z) == other.get(x,y,z)
    end
    return true
  end

end
