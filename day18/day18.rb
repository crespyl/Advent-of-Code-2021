#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'

require 'set'
require 'pqueue'

require '../util/grid'

TEST_2 = "\
[1,1]
[2,2]
[3,3]
[4,4]
"

TEST_3 = "\
[1,1]
[2,2]
[3,3]
[4,4]
[5,5]
"

TEST_4 = "\
[1,1]
[2,2]
[3,3]
[4,4]
[5,5]
[6,6]
"

TEST_5 = "\
[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
"

TEST_6 = "\
[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(445, compute_p1(TEST_2))
    assert_equal(791, compute_p1(TEST_3))
    assert_equal(1137, compute_p1(TEST_4))
    assert_equal(3488, compute_p1(TEST_6))
    assert_equal(4140, compute_p1(TEST_5))
  end

  def test_p2
    assert_equal(3993, compute_p2(TEST_5))
  end
end

def add_to_first(node, value)
  if node.is_a? Array
    [add_to_first(node[0], value), node[1]]
  else
    node + value
  end
end

def add_to_last(node, value)
  if node.is_a? Array
    [node[0], add_to_last(node[1], value)]
  else
    node + value
  end
end

def reduce(n)
  loop do
    if can_explode?(n)
      n = explode(n)
    elsif can_split?(n)
      n = split(n)
    else
      return n
    end
  end
end

def can_explode?(n)
  explode(n) != n
end

def can_split?(n)
  split(n) != n
end

def explode(n)
  apply_explode(n, 0)[:value]
end

def apply_explode(n, depth=0)
  n = n.clone
  return {explode: false, going_left: 0, going_right: 0, value: n} unless n.is_a? Array

  if depth >= 4
    raise "tried to explode complex pair #{n} at depth #{depth}" unless n.all? { _1.is_a? Fixnum }

    return {explode: true, going_left: n[0], going_right: n[1], value: 0}
  else

    try_left = apply_explode(n[0], depth+1)

    if try_left[:explode]
      n[1] = add_to_first(n[1], try_left[:going_right])
      return {explode: true, going_left: try_left[:going_left], going_right: 0, value: [try_left[:value], n[1]]}
    end

    try_right = apply_explode(n[1], depth+1)
    if try_right[:explode]
      n[0] = add_to_last(n[0], try_right[:going_left])
      return {explode: true, going_left: 0, going_right: try_right[:going_right], value: [n[0], try_right[:value]]}
    end

    return {explode: false, going_left: 0, going_right: 0, value: n}
  end
end

def magnitude(n)
  return n unless n.is_a? Array
  3 * magnitude(n[0]) + 2 * magnitude(n[1])
end

def split(n)
  split_once(n)[0]
end

def split_once(n, did_split=false)
  return [n, did_split] if did_split

  if (n.is_a? Fixnum) && n >= 10
    [[(n/2.0).floor, (n/2.0).ceil], true]
  elsif n.is_a? Fixnum
    [n, false]
  elsif n.is_a? Array
    split_nodes = n.map do |node|
      if did_split
        node
      else
        split_node, did_split = split_once(node, did_split)
        split_node
      end
    end
    [split_nodes, did_split]
  end
end

def add(a, b)
  [a, b]
end

def sum_list(list)
  list[1..].reduce(list[0]) { |sum, n| reduce(add(sum, n)) }
end

def compute_p1(input)
  numbers = input.lines.map(&:chomp).map { eval(_1) }
  sum = sum_list(numbers)
  magnitude(sum)
end

def compute_p2(input)
  numbers = input.lines.map(&:chomp).map { eval(_1) }

  best = 0
  numbers.combination(2).each do |a, b|
    a_b = magnitude(reduce(add(a,b)))
    best = a_b if a_b > best
    b_a = magnitude(reduce(add(b,a)))
    best = b_a if b_a > best
  end

  best
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
