#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

TEST_STR = "\
16,1,2,0,4,2,7,1,2,14
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(37, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(168, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  numbers = input.split(',').map(&:to_i)
  best_fuel_use = 9999999999999
  numbers.max.times do |tgt|
    total = numbers
              .map { |v| (v-tgt).abs }
              .sum

    best_fuel_use = total if total < best_fuel_use
  end

  best_fuel_use
end

def compute_p2(input)
  numbers = input.split(',').map(&:to_i)

  best_fuel_use = 9999999999999
  numbers.max.times do |tgt|
    total = numbers
              .map { |v| diff = (v-tgt).abs; diff * (diff+1) / 2 }
              .sum

    best_fuel_use = total if total < best_fuel_use
  end

  best_fuel_use
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
