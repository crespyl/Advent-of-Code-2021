#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'

TEST_STR = "\
199
200
208
210
200
207
240
269
260
263
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(7, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(5, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  input.lines.map(&:to_i).each_cons(2).reduce(0) do |sum, pair|
    pair.last > pair.first ? sum + 1 : sum
  end
end

def compute_p2(input)
  input
    .lines
    .map(&:to_i)
    .each_cons(3)
    .map(&:sum)
    .each_cons(2)
    .reduce(0) { |sum, pair| pair.last > pair.first ? sum + 1 : sum }
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
