#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

TEST_STR = "\
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(5, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(12, compute_p2(TEST_STR))
  end
end

def line_points(a, b)
  points = []
  cur_x, cur_y = a

  until cur_x == b[0] && cur_y == b[1]
    points << [cur_x, cur_y]

    cur_x += 1 if a[0] < b[0]
    cur_x -= 1 if a[0] > b[0]

    cur_y += 1 if a[1] < b[1]
    cur_y -= 1 if a[1] > b[1]
  end

  points << b
end

def print_map(map)
  y = 0
  while y < 10
    x = 0
    while x < 10
      print map[[x,y]] == 0 ? '.' : map[[x,y]]
      x += 1
    end
    y += 1
    print "\n"
  end
end

def compute_p1(input)
  map = Hash.new(0)

  input.lines.each do |line|
    start, finish = line.split(' -> ').map { _1.split(',').map(&:to_i) }
    next unless start[0] == finish[0] || start[1] == finish[1]

    line_points(start, finish).each do |point|
      map[point] += 1
    end
  end

  map.values.count { _1 > 1 }
end

def compute_p2(input)
  map = Hash.new(0)

  input.lines.each do |line|
    start, finish = line.split(' -> ').map { _1.split(',').map(&:to_i) }
    #next unless start[0] == finish[0] || start[1] == finish[1]

    line_points(start, finish).each do |point|
      map[point] += 1
    end
  end

  map.values.count { _1 > 1 }
end

if MiniTest.run
  puts 'Test case OK, running...'

  @input = File.read(ARGV[0] || 'input.txt')
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
