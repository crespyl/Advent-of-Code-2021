#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

require '../util/grid'

TEST_STR = "\
2199943210
3987894921
9856789892
8767896789
9899965678
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(15, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(1134, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  sum = 0
  grid = Grid.new(input)
  grid.each_index do |x,y|
    value = grid.get(x,y).to_i
    neighbors = grid.neighbors(x,y).reject {_1.nil?}.map(&:to_i)
    sum += (1+value) if neighbors.all? { _1 > value }
  end
  return sum
end

def compute_p2(input)
  grid = Grid.new(input)

  low_points = []
  grid.each_index do |x,y|
    value = grid.get(x,y).to_i
    neighbors = grid.neighbors(x,y).reject {_1.nil?}.map(&:to_i)
    low_points.push([x,y]) if neighbors.all? { _1 > value }
  end

  basin_sizes = Hash.new(0)

  low_points.each do |point|
    visited = []
    open_set = [point]

    until open_set.empty?
      cur_x, cur_y = open_set.shift
      visited.push([cur_x, cur_y])

      [
                 [0, -1],
        [-1,  0],        [+1, 0],
                 [0, +1]
      ].each do |dx, dy|
        nx, ny = cur_x + dx, cur_y + dy
        next if visited.include?([nx, ny]) || open_set.include?([nx,ny])

        cell = grid.get(nx, ny)
        next if cell.nil? || cell == '9'

        open_set.push([nx, ny])
      end
    end

    basin_sizes[point] += visited.uniq.size
  end

  basin_sizes.values.sort[-3..].inject(:*)
end

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
