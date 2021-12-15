#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'
require 'pqueue'

require '../util/grid'

TEST_STR = "\
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(40, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(315, compute_p2(TEST_STR))
  end
end

def path_dist(grid, start, goal)
  visited = Set.new
  open = PQueue.new([[start, 0]]) { |a,b| a.last < b.last }

  until open.empty?
    node, dist = open.pop

    next unless visited.add?(node)
    return dist if node == goal

    frontier = [
             [0, -1],
      [-1,0],        [1, 0],
             [0, +1]
    ].map { |dx, dy| [node[0]+dx, node[1]+dy] }
     .filter { |nx,ny| grid.in_bounds?(nx,ny) }

    frontier.each do |nx,ny|
      open.push([[nx,ny], dist + grid.get(nx,ny)])
    end
  end
end

def compute_p1(input)
  grid = Grid.new(input)
  grid.update do |_x, _y, value|
    value.to_i
  end

  start = [0,0]
  goal = [grid.width-1, grid.height-1]

  path_dist(grid, start, goal)
end

def wrap(n)
  n > 9 ? n % 9 : n
end

def compute_p2(input)
  grid = Grid.new(input)
  grid.update do |_x, _y, value|
    value.to_i
  end

  new_width = grid.width*5
  new_height = grid.height*5
  new_grid = {}

  grid.each_index do |x,y|
    5.times do |i|
      5.times do |j|
        new_grid[[x + (grid.width * j), y + (grid.height * i)]] = wrap(grid.get(x,y) + i + j)
      end
    end
    new_grid[[x,y]] = grid.get(x,y)
  end

  rows = []
  new_height.times do |row|
    column = []
    new_width.times do |col|
      column.push(new_grid[[col,row]])
    end
    rows.push(column)
  end

  grid.width = new_width
  grid.height = new_height
  grid.grid = rows

  start = [0,0]
  goal = [grid.width-1, grid.height-1]

  path_dist(grid, start, goal)
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
  puts 'Part 2: %s' % @p2 if do_p2

else
  puts 'Test case ERR'
end
