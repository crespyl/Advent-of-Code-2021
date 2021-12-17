#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'

require 'set'
require 'pqueue'

require '../util/grid'

TEST_STR = "\
target area: x=20..30, y=-10..-5
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(45, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(112, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  matches = input.chomp.match(/target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)/)
  x_min, x_max, y_min, y_max = matches[1..].map(&:to_i)

  x_range = x_min..x_max
  y_range = y_min..y_max

  ((Math.sqrt(x_min*2).floor)..x_max).to_a
    .product((y_min..(y_min.abs-1)).to_a)
    .reduce(0) do |best, coords|
    hit, max_y = test_probe(coords[0], coords[1], x_range, y_range)
    hit ? [best, max_y].max : best
  end
end

def test_probe(vx, vy, x_range, y_range)
  x,y = 0,0
  max_y = 0
  loop do
    return [true, max_y] if x_range.include?(x) && y_range.include?(y)
    return [false, max_y] if x > x_range.max || y < y_range.min || (! x_range.include?(x) && vx == 0)

    x += vx
    y += vy

    max_y = y if y > max_y

    vx = (vx - (vx <=> 0)) # approach 0
    vy -= 1
  end
end

def compute_p2(input)
  matches = input.chomp.match(/target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)/)
  x_min, x_max, y_min, y_max = matches[1..].map(&:to_i)

  x_range = x_min..x_max
  y_range = y_min..y_max

  ((Math.sqrt(x_min*2).floor)..x_max).to_a
    .product((y_min..(y_min.abs-1)).to_a)
    .reduce(0) do |sum, coords|
    hit, _max_y = test_probe(coords[0], coords[1], x_range, y_range)
    hit ? sum + 1 : sum
  end
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
