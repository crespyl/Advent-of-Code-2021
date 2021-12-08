#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

TEST_STR = "\
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
"

TEST_STR_2 = "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf"

class Test < MiniTest::Test
  def test_p1
    assert_equal(26, compute_p1(TEST_STR))
  end

  def test_decode
    assert_equal(5353, decode(TEST_STR_2))
  end

  def test_p2
    assert_equal(61229, compute_p2(TEST_STR))
  end
end

#
# 0:      1:      2:      3:      4:
#  aaaa    ....    aaaa    aaaa    ....
# b    c  .    c  .    c  .    c  b    c
# b    c  .    c  .    c  .    c  b    c
#  ....    ....    dddd    dddd    dddd
# e    f  .    f  e    .  .    f  .    f
# e    f  .    f  e    .  .    f  .    f
#  gggg    ....    gggg    gggg    ....
#
#  5:      6:      7:      8:      9:
#  aaaa    aaaa    aaaa    aaaa    aaaa
# b    .  b    .  .    c  b    c  b    c
# b    .  b    .  .    c  b    c  b    c
#  dddd    dddd    ....    dddd    dddd
# .    f  e    f  .    f  e    f  .    f
# .    f  e    f  .    f  e    f  .    f
#  gggg    gggg    ....    gggg    gggg
#

# digits with uniq segment active counts
# 1 : 2
# 4 : 4
# 7 : 3
# 8 : 7

def compute_p1(input)
  sum = 0
  input
    .lines
    .map(&:chomp)
    .map { _1.split(' | ').last }
    .map { _1.split(' ') }
    .map { _1.map(&:size) }
    .each do |outputs|
    sum += (outputs.count(2) + outputs.count(4) + outputs.count(3) + outputs.count(7))
  end
  return sum
end

def decode(line)
  inputs, outputs = line.split(' | ').map {_1.split(' ')}
  # find the two signals for a '1'
  digit_1 = inputs.select{_1.size == 2}.first.chars.to_set

  # find the 4 signals for a '4'
  digit_4 = inputs.select{_1.size == 4}.first.chars.to_set

  # find the 3 signals for a '7'
  digit_7 = inputs.select{_1.size == 3}.first.chars.to_set

  # find the 7 signals for a '8'
  digit_8 = inputs.select{_1.size == 7}.first.chars.to_set

  # top segment 'a' is the difference between 1 and 7
  segment_a = digit_7 - digit_1

  # there are three digits with 6 lit segments, 0, 6, and 9
  # of those, all three have both segments from 1, except for 6 which only has the lower one
  digits_069 = inputs
                 .select{_1.size == 6}
                 .map {_1.chars.to_set}

  digit_6 = digits_069.reject { _1.superset?(digit_1) }.first

  segment_c = digit_1 - digit_6
  segment_f = digit_1 - segment_c

  segments_bd = (digit_6 & digit_4) - digit_1
  digit_0 = digits_069.reject {_1.superset?(segments_bd)}.first
  segment_d = segments_bd - digit_0
  segment_b = segments_bd - segment_d

  digits_235 = inputs
                 .select{_1.size == 5}
                 .map {_1.chars.to_set}

  segment_g = digits_235.map {_1 - segment_a - segment_b - segment_c - segment_d - segment_f}
                .inject(:&)

  segment_e = digit_8 - segment_a - segment_b - segment_c - segment_d - segment_f - segment_g

  # ok we have all the segments mapped out
  # now make the remaining digits

  #digit_0
  #digit_1
  digit_2 = digit_8 - segment_b - segment_f
  digit_3 = digit_8 - segment_b - segment_e
  #digit_4
  digit_5 = digit_8 - segment_c - segment_e
  #digit_6
  #digit_7
  #digit_8
  digit_9 = digit_8 - segment_e

  digits = {
    digit_0 => '0',
    digit_1 => '1',
    digit_2 => '2',
    digit_3 => '3',
    digit_4 => '4',
    digit_5 => '5',
    digit_6 => '6',
    digit_7 => '7',
    digit_8 => '8',
    digit_9 => '9'
  }

  outputs.map{_1.chars.to_set}.map{digits[_1]}.join.to_i

end

def compute_p2(input)
  input
    .lines
    .map {decode(_1)}
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
