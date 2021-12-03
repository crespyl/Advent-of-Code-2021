#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

TEST_STR = "\
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(198, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(230, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  zeroes = Hash.new(0)
  ones = Hash.new(0)

  input
    .lines
    .map(&:chomp)
    .each do |line|
    line.chars.each_with_index do |char, i|
      case char
      when '0'
        zeroes[i] += 1
      when '1'
        ones[i] += 1
      end
    end
  end

  gamma = zeroes
            .sort
            .zip(ones.sort)
            .map { |zs,os| zs[1] > os[1] ? 0 : 1 }
            .join('')
            .to_i(2)

  epsilon = zeroes
              .sort
              .zip(ones.sort)
              .map { |zs,os| zs[1] < os[1] ? 0 : 1 }
              .join('')
              .to_i(2)

  gamma * epsilon
end

def compute_p2(input)
  numbers = input.lines.map(&:chomp)
  zeroes, ones = count_bits(numbers)

  oxygen_gen_rating_set = Set.new(numbers)
  bit_criteria_idx = 0
  while oxygen_gen_rating_set.size > 1
    tgt = ones[bit_criteria_idx] >= zeroes[bit_criteria_idx] ? '1' : '0'
    oxygen_gen_rating_set = oxygen_gen_rating_set.filter { _1[bit_criteria_idx] == tgt }
    bit_criteria_idx += 1
    zeroes, ones = count_bits(oxygen_gen_rating_set)
  end

  oxygen_gen_rating = oxygen_gen_rating_set.first.to_i(2)

  co2_scrubber_rating_set = Set.new(numbers)
  bit_criteria_idx = 0
  while co2_scrubber_rating_set.size > 1
    tgt = ones[bit_criteria_idx] < zeroes[bit_criteria_idx] ? '1' : '0'
    co2_scrubber_rating_set = co2_scrubber_rating_set.filter { _1[bit_criteria_idx] == tgt }
    bit_criteria_idx += 1
    zeroes, ones = count_bits(co2_scrubber_rating_set)
  end

  co2_scrubber_rating = co2_scrubber_rating_set.first.to_i(2)

  return oxygen_gen_rating * co2_scrubber_rating
end

def count_bits(numbers)
  zeroes = Hash.new(0)
  ones = Hash.new(0)

  numbers.each do |number|
    number.chars.each_with_index do |char, i|
      case char
      when '0'
        zeroes[i] += 1
      when '1'
        ones[i] += 1
      end
    end
  end

  [zeroes, ones]
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
