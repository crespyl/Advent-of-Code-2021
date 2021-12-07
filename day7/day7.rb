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
  (0..numbers.max).reduce(1/0.0) do |best, tgt|
    total = numbers
              .map { (_1 - tgt).abs }
              .sum

    total < best ? total : best
  end
end

def compute_p2(input)
  numbers = input.split(',').map(&:to_i)

  (0..numbers.max).reduce(1/0.0) do |best, tgt|
    total = numbers
              .map { diff = (_1 - tgt).abs; diff * (diff + 1) / 2 }
              .sum

    total < best ? total : best
  end
end

def golf_p2(input)
  n=input.split(',').map(&:to_i)
  (0..n.max).reduce(1/0.0){|b,t|f=n.map{d=(_1-t).abs;d*(d+1)/2}.sum;f<b ? f : b}
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
