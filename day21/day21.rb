#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'

require 'set'
require 'pqueue'

require '../util/grid'

TEST_STR = "\
Player 1 starting position: 4
Player 2 starting position: 8
"


class Test < MiniTest::Test
  def test_p1
    assert_equal(739785, compute_p1(TEST_STR))
  end

  # def test_p2
  #   assert_equal(444356092776315, compute_p2(TEST_STR))
  # end
end

class DDice
  def initialize()
    @max = 100
    @next_roll = 1
    @total_rolls = 0
  end

  def total_rolls
    @total_rolls
  end

  def roll
    @total_rolls += 1
    result = @next_roll

    @next_roll = @next_roll + 1
    @next_roll = 1 if @next_roll > @max

    return result
  end

  def roll_n(n)
    (0...n).map { roll }
  end
end

def wrap(n)
  n -= 10 until n <= 10
  n
end

def compute_p1(input)
  p1_pos = input.lines[0].chomp.chars.last.to_i
  p2_pos = input.lines[1].chomp.chars.last.to_i

  p1_score = 0
  p2_score = 0

  die = DDice.new

  loop do
    p1_rolls = die.roll_n(3)
    p1_step = p1_rolls.sum
    p1_pos = wrap(p1_pos + p1_step)
    p1_score += p1_pos
    # puts "Player 1 rolls #{p1_rolls.join('+')} and moves to space #{p1_pos} for a total score of #{p1_score}"
    break if p1_score >= 1000

    p2_rolls = die.roll_n(3)
    p2_step = p2_rolls.sum
    p2_pos = wrap(p2_pos + p2_step)
    p2_score += p2_pos
    # puts "Player 2 rolls #{p2_rolls.join('+')} and moves to space #{p2_pos} for a total score of #{p2_score}"
    break if p2_score >= 1000
  end

  winner = p1_score >= 1000 ? 'p1' : 'p2'
  loser  = p1_score >= 1000 ? 'p2' : 'p1'
  puts "#{winner} wins with #{[p1_score, p2_score].max} points, after #{die.total_rolls} rolls"
  puts "#{loser} loses with #{[p1_score, p2_score].min} points, after #{die.total_rolls} rolls"

  (([p1_score, p2_score].min) * die.total_rolls)
end

# def compute_p2(input)


# end

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
