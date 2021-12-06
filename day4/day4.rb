#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

TEST_STR = "\
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(4512, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(1924, compute_p2(TEST_STR))
  end
end

class Board
  def initialize(rows)
    @rows = rows
    @hits = Set.new
  end

  def mark(number)
    @hits += [number]
  end

  def win?
    return false unless @hits.size >= 5

    @rows.size.times do |i|
      # check if every number in row i is in @hits
      return true if @hits.superset? @rows[i].to_set

      # check if every number in column i is in @hits
      return true if @hits.superset? @rows.reduce([]) { |column, row| column << row[i] }
                                          .to_set
    end

    return false
  end

  def unmarked_numbers
    @rows.flatten.to_set - @hits
  end
end

def compute_p1(input)
  numbers = input
            .lines
            .first
            .chomp
            .split(',')
            .map(&:to_i)

  boards = input
           .split("\n\n")
           .drop(1)
           .map { |l| l.split("\n").map { _1.split(' ').map(&:to_i) } }
           .map { Board.new(_1) }

  winner = nil
  number = nil

  until numbers.empty?
    number = numbers.shift
    boards.each { _1.mark(number) }

    break if (winner = boards.select { _1.win? }.first)
  end

  winner.unmarked_numbers.sum * number
end

def compute_p2(input)
  numbers = input
            .lines
            .first
            .chomp
            .split(',')
            .map(&:to_i)

  boards = input
           .split("\n\n")
           .drop(1)
           .map { |l| l.split("\n").map { _1.split(' ').map(&:to_i) } }
           .map { Board.new(_1) }

  last_board = nil
  number = nil

  until numbers.empty? || last_board&.win?
    number = numbers.shift
    boards.each { _1.mark(number) }

    boards = boards.filter { ! _1.win? }
    last_board = boards.first if boards.size == 1
  end

  last_board.unmarked_numbers.sum * number
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
