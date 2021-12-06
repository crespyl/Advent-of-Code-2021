#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

TEST_STR = "\
3,4,3,1,2
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(5934, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(26984457539, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  fishmap = [0, 0, 0, 0, 0, 0, 0, 0, 0]
  input.split(',').map(&:to_i).each { fishmap[_1] += 1 } # count how many of each stage there is

  80.times do
    num_reproducing = fishmap.shift
    fishmap[6] += num_reproducing
    fishmap.append(num_reproducing)
  end

  fishmap.sum
end

def compute_p2(input)
  fishmap = [0, 0, 0, 0, 0, 0, 0, 0, 0]
  input.split(',').map(&:to_i).each { fishmap[_1] += 1 } # count how many of each stage there is

  256.times do
    num_reproducing = fishmap.shift
    fishmap[6] += num_reproducing
    fishmap.append(num_reproducing)
  end

  fishmap.sum
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
