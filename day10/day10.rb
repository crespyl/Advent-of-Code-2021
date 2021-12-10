#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

require '../util/grid'

TEST_STR = "\
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(26397, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(288957, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  parens = {
    '(' => ')',
    '[' => ']',
    '{' => '}',
    '<' => '>'
  }

  points = {
    ')' => 3,
    ']' => 57,
    '}' => 1197,
    '>' => 25137
  }

  input.lines.map(&:chomp).reduce(0) do |sum, line|
    expect_stack = []
    line.chars.each do |char|
      if parens.keys.include?(char)
        expect_stack.push(parens[char])
      elsif parens.values.include?(char) && expect_stack.pop != char
        sum += points[char]
      end
    end
    sum
  end
end

def compute_p2(input)
  parens = {
    '(' => ')',
    '[' => ']',
    '{' => '}',
    '<' => '>'
  }

  points = {
    ')' => 1,
    ']' => 2,
    '}' => 3,
    '>' => 4
  }

  scores = input
             .lines
             .map(&:chomp)
             .filter { compute_p1(_1) == 0 }
             .map do |line|
    expect_stack = []
    line.chars.each do |char|
      if parens.keys.include?(char)
        expect_stack.push(parens[char])
      elsif parens.values.include?(char) && expect_stack.pop != char
        #binding.pry
      end
    end
    expect_stack.reverse.reduce(0) { |sum,char| (sum * 5) + points[char] }
  end

  scores.sort[scores.size/2]
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
