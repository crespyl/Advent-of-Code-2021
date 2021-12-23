#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'
require 'ostruct'

require '../util/grid'

TEST_STR = "\
on x=-20..26,y=-36..17,z=-47..7
on x=-20..33,y=-21..23,z=-26..28
on x=-22..28,y=-29..23,z=-38..16
on x=-46..7,y=-6..46,z=-50..-1
on x=-49..1,y=-3..46,z=-24..28
on x=2..47,y=-22..22,z=-23..27
on x=-27..23,y=-28..26,z=-21..29
on x=-39..5,y=-6..47,z=-3..44
on x=-30..21,y=-8..43,z=-13..34
on x=-22..26,y=-27..20,z=-29..19
off x=-48..-32,y=26..41,z=-47..-37
on x=-12..35,y=6..50,z=-50..-2
off x=-48..-32,y=-32..-16,z=-15..-5
on x=-18..26,y=-33..15,z=-7..46
off x=-40..-22,y=-38..-28,z=23..41
on x=-16..35,y=-41..10,z=-47..6
off x=-32..-23,y=11..30,z=-14..3
on x=-49..-5,y=-3..45,z=-29..18
off x=18..30,y=-20..-8,z=-3..13
on x=-41..9,y=-7..43,z=-33..15
on x=-54112..-39298,y=-85059..-49293,z=-27449..7877
on x=967..23432,y=45373..81175,z=27513..53682
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(590784, compute_p1(TEST_STR))
  end

  # def test_p2
  #   assert_equal(288957, compute_p2(TEST_STR))
  # end
end

LINE_RE = /(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)/

def make_block(x_min, x_max, y_min, y_max, z_min, z_max)
  block = OpenStruct.new(
    x_min: x_min,
    x_max: x_max,
    y_min: y_min,
    y_max: y_max,
    z_min: z_min,
    z_max: z_max
  )
end

def intersect?(a, b)
  left = [a, b].sort_by { _1.x_min }.first
  right = ([a, b] - [left]).first
  x_intersect = left.x_min <= right.x_min && left.x_max >= right.x_min

  top = [a, b]
           .sort_by { _1.y_min }
           .first
  bottom = ([a, b] - [top]).first
  y_intersect = top.y_min <= bottom.y_min && top.y_max >= bottom.y_max

  shallow = [a, b]
              .sort_by { _1.z_min }
              .first
  deep = ([a, b] - [shallow]).first
  z_intersect = shallow.z_min <= deep.z_min && shallow.z_max >= deep.z_max

  x_intersect && y_intersect && z_intersect
end

def set_block(map, value, block)
  (block.x_min..block.x_max).each do |x|
    (block.y_min..block.y_max).each do |y|
      (block.z_min..block.z_max).each do |z|
        map[[x,y,z]] = value
      end
    end
  end
end

def count_block(map, value, block)
  [(block.x_min..block.x_max).to_a,
   (block.y_min..block.y_max).to_a,
   (block.z_min..block.z_max).to_a]
    .inject(&:product)
    .map(&:flatten) # list of coords in block
    .reduce(0) do |sum, point|
    map[point] == value ? sum + 1 : sum
  end
end

def compute_p1(input)
  map = Hash.new(false)

  center50 = make_block(-50, 50, -50, 50, -50, 50)
  blocks = []
  block_state = {}

  input.lines.each do |line|
    set = line.match(LINE_RE)[1]
    x_min, x_max, y_min, y_max, z_min, z_max = line.match(LINE_RE)[2..].map(&:to_i)

    block =  make_block(x_min, x_max,
                        y_min, y_max,
                        z_min, z_max)

    block_state[block] = (set == "on")
    blocks << block
  end

  blocks.filter { intersect?(center50, _1) }.each do |block|
    set_block(map, block_state[block], block)
  end

  count_block(map, true, center50)
end

# def compute_p2(input)

# end

if MiniTest.run
  puts 'Test case OK, running...'

  @input = File.read(ARGV[0] || File.join(File.dirname(__FILE__), 'input.txt'))
  do_p2 = defined?(compute_p2)

  Benchmark.bm do |bm|
    bm.report('Part 1:') { @p1 = compute_p1(@input) }
    bm.report('Part 2:') { @p2 = compute_p2(@input) } if do_p2
  end

  puts "\nResults:"
  puts 'Part 1: %i' % @p1
  puts 'Part 2: %i' % @p2 if do_p2

else
  puts 'Test case ERR'
end
