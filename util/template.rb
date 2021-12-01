#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'

TEST_STR = "\

"

class Test < MiniTest::Test
  def test_p1
    assert_equal(0, compute_p1(TEST_STR))
  end

  # def test_p2
  #   assert_equal(0, compute_p2(TEST_STR))
  # end
end

def compute_p1(input)

end

def compute_p2(input)

end

if $0 == __FILE__ && MiniTest.run
  puts "Test case OK, running..."

  @input = File.read(ARGV[0] || "input.txt")

  Benchmark.bm do |bm|
    bm.report("Part 1:") { @p1 = compute_p1(@input) }
    #bm.report("Part 2:") { @p2 = compute_p2(@input) }
  end

  puts "\nResults:"
  puts "Part 1: %i" % @p1
  #puts "Part 2: %i" % @p2

else
  puts "Test case ERR"
end
