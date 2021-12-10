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

def test_line(line)
  score = 0
  stack = []
  line.chars.each_with_index do |char, idx|
    if '([{<'.chars.include?(char)
      stack.push char
    elsif ')]}>'.chars.include?(char)
      last_pushed = stack.pop
      if char == ')' && last_pushed != '(' ||
         char == ']' && last_pushed != '[' ||
         char == '>' && last_pushed != '<' ||
         char == '}' && last_pushed != '{'
        # unexpected closing bracket
        score += case char
                 when ')' then 3
                 when ']' then 57
                 when '}' then 1197
                 when '>' then 25137
                 end
      end
    end
  end

  return score
end

def fix_line(line)
  score = 0
  stack = []
  line.chars.each_with_index do |char, idx|
    if '([{<'.chars.include?(char)
      stack.push char
    elsif ')]}>'.chars.include?(char)
      last_pushed = stack.pop
      if char == ')' && last_pushed != '(' ||
         char == ']' && last_pushed != '[' ||
         char == '>' && last_pushed != '<' ||
         char == '}' && last_pushed != '{'
        # unexpected closing bracket
        binding.pry
        puts "unexpected char #{char} at #{idx}"
      end
    end
  end

  until stack.empty?
    char = stack.pop
    value = case char
    when '(' then 1
    when '[' then 2
    when '{' then 3
    when '<' then 4
    end
    score = (score * 5) + value
  end

  return score
end

def compute_p1(input)
  score = 0

  input.lines.map(&:chomp).each do |line|
    score += test_line(line)
  end

  return score
end

def compute_p2(input)
  scores = input
             .lines
             .map(&:chomp)
             .filter { test_line(_1) == 0 }
             .map { fix_line(_1) }
             .sort
  return scores[scores.size/2]
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
