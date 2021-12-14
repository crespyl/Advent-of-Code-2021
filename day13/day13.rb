#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

require '../util/grid'

TEST_STR = "\
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(17, compute_p1(TEST_STR))
  end

  # def test_p2
  #   assert_equal(36, compute_p2(TEST_STR))
  # end
end

def compute_p1(input)
  dots, instructions = input.split("\n\n")

  grid = Hash.new(false)

  dots
    .lines
    .map(&:chomp)
    .map { _1.split(',') }
    .map { _1.map(&:to_i) }
    .each do |x,y|
    grid[[x,y]] = true
  end

  apply_fold(grid, instructions.lines.first)

  grid.values.count(true)
end

def compute_p2(input)
  dots, instructions = input.split("\n\n")

  grid = Hash.new(false)

  dots
    .lines
    .map(&:chomp)
    .map { _1.split(',') }
    .map { _1.map(&:to_i) }
    .each do |x, y|
    grid[[x, y]] = true
  end

  instructions.lines.each do |line|
    apply_fold(grid, line)
  end

  "\n#{format_grid(grid)}\n"
end

def apply_fold(grid, instruction)
  axis, value = instruction.match(/(x|y)=(\d+)/)[1..]
  value = value.to_i

  grid.keys.each do |x,y|
    new_x, new_y = case axis
                   when 'x'
                     next unless x > value
                     [value - (x - value), y]
                   when 'y'
                     next unless y > value
                     [x, value - (y - value)]
                   end

    grid[[new_x, new_y]] = true
    grid.delete([x, y])
  end
end

def format_grid(grid)
  string = ""
  width = grid.keys.map { _1[0] }.max
  height = grid.keys.map { _1[1] }.max

  (height+1).times do |y|
    (width+1).times do |x|
      if grid[[x,y]]
        string += '██'
      else
        string += '░░'
      end
    end
    string += "\n"
  end

  string
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
