#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'

TEST_STR = "\
forward 5
down 5
forward 8
up 3
down 8
forward 2
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(150, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(900, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  pos_horizontal = 0
  pos_depth = 0

  input
    .lines
    .map { _1.match(/^(\w+)\s+(\d+)$/) }
    .map { [_1[1], _1[2].to_i] }
    .each do |command|
    case command[0]
    when "forward"
      pos_horizontal += command[1]
    when "down"
      pos_depth += command[1]
    when "up"
      pos_depth -= command[1]
    else
      raise "unknown command: #{command}"
    end
  end

  return pos_horizontal * pos_depth
end

def compute_p2(input)
  pos_horizontal = 0
  pos_depth = 0
  aim = 0

  input
    .lines
    .map { _1.match(/^(\w+)\s+(\d+)$/) }
    .map { [_1[1], _1[2].to_i] }
    .each do |command|
    case command[0]
    when "forward"
      pos_horizontal += command[1]
      pos_depth += aim * command[1]
    when "down"
      aim += command[1]
    when "up"
      aim -= command[1]
    else
      raise "unknown command: #{command}"
    end
  end

  return pos_horizontal * pos_depth
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
