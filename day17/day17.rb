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

  best_x = 0
  best_y = 0
  best_max_y = 0

  x_range.max.times do |x|
    x_range.max.times do |y|
      hit, max_y = test_probe(x,y, x_range, y_range)
      if hit && max_y > best_max_y
        best_x = x
        best_y = y
        best_max_y = max_y
      end
    end
  end

  return best_max_y
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

  y_max = compute_p1(input)
  hits = 0

  (x_range.max+1).times do |x|
    ((y_range.min)..y_max).each do |y|
      hit, _max_y = test_probe(x,y, x_range, y_range)
      hits += 1 if hit
    end
  end

  return hits
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
