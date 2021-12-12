#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

require '../util/grid'

TEST_STR = "\
start-A
start-b
A-c
A-b
b-d
A-end
b-end
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(10, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(36, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  connections = Hash.new { Set.new }

  input
    .lines
    .map(&:chomp)
    .map { _1.split('-') }
    .each do |a, b|
    connections[a] += [b]
    connections[b] += [a]
  end

  count_paths_p1(connections, 'start')
end

def count_paths_p1(connections, start, visited_small_caves = Set.new)
  return 1 if start == 'end'

  frontier = connections[start] - visited_small_caves

  return 0 if frontier.empty?

  visited_small_caves += [start] if start.match?(/[[:lower:]]/)
  frontier
    .map { count_paths_p1(connections, _1, visited_small_caves) }
    .sum
end

def compute_p2(input)
  connections = Hash.new { Set.new }

  input
    .lines
    .map(&:chomp)
    .map { _1.split('-') }
    .each do |a, b|
    connections[a] += [b]
    connections[b] += [a]
  end

  count_paths_p2(connections, 'start', Set.new(['start']))
end

def count_paths_p2(connections, node, closed_caves = Set.new, visit_counts = Hash.new(0))
  return 1 if node == 'end'

  if node.match?(/[[:lower:]]/)
    visit_counts[node] += 1
    if visit_counts[node] >= 2
      closed_caves += visit_counts.keys
    elsif visit_counts.values.include?(2)
      closed_caves += [node]
    end
  end

  frontier = connections[node] - closed_caves
  return 0 if frontier.empty?

  frontier
    .map { count_paths_p2(connections, _1, closed_caves.clone, visit_counts.clone) }
    .sum
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
