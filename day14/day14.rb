#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

require '../util/grid'

TEST_STR = "\
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(1588, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(2188189693529, compute_p2(TEST_STR))
  end
end

def parse(input)
  template, rules = input.split("\n\n")

  rules = rules
            .lines
            .map(&:chomp)
            .map { _1.split(' -> ') }
            .map { |k,v| [k, [k[0] + v, v + k[1], v]] }
            .to_h

  pairs = template
            .chars
            .each_cons(2)
            .map(&:join)
            .reduce(Hash.new(0)) { |h, pair| h[pair] += 1; h }

  counts = template
             .chars
             .reduce(Hash.new(0)) { |h,c| h[c] += 1; h }

  [pairs, counts, rules]
end

def compute_p1(input)
  pairs, counts, rules = parse(input)

  10.times { apply_rules(pairs, counts, rules) }

  scores = counts.values.sort
  scores.last - scores.first
end

def compute_p2(input)
  pairs, counts, rules = parse(input)

  40.times { apply_rules(pairs, counts, rules) }

  scores = counts.values.sort
  scores.last - scores.first
end

def apply_rules(pairs, counts, rules)
  pair_deltas = Hash.new(0)
  count_deltas = Hash.new(0)

  pairs.keys.filter{ pairs[_1] > 0 }.each do |key|
    count = pairs[key]
    pair_deltas[key] -= count
    rules[key][0..1].each { pair_deltas[_1] += count }
    count_deltas[rules[key].last] += count
  end

  pair_deltas.each { |k,v| pairs[k] += pair_deltas[k] }
  count_deltas.each { |k,v| counts[k] += count_deltas[k] }
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
