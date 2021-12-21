#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'

require 'set'
require 'pqueue'

require '../util/grid'

TEST_STR = "\
..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###"

TEST_STR2= "\
..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

.....
.....
..#..
.....
....."


class Test < MiniTest::Test
  def test_p1
    assert_equal(35, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(3351, compute_p2(TEST_STR))
  end
end

def enhancement_index(map, x, y)
  [
    [-1, -1], [0, -1], [+1, -1],
    [-1,  0], [0,  0], [+1,  0],
    [-1, +1], [0, +1], [+1, +1]
  ].map { |dx, dy| [x + dx, y + dy] }
   .map { |nx, ny| map[[nx,ny]] }
   .join
   .tr('.#', '01')
   .to_i(2)
end

def enhance_map(map, enhancement)
  min_x = map.keys.map { |k| k[0] }.min
  max_x = map.keys.map { |k| k[0] }.max
  min_y = map.keys.map { |k| k[1] }.min
  max_y = map.keys.map { |k| k[1] }.max

  output = Hash.new('.')
  output.default = enhancement[enhancement_index(map, 999999999, 999999999)]

  ((min_x-1)..(max_x+1)).each do |x|
    ((min_y-1)..(max_y+1)).each do |y|
      output[[x,y]] = enhancement[enhancement_index(map, x, y)]
    end
  end

  return output
end

def print_map(map)
  min_x = map.keys.map { |k| k[0] }.min
  max_x = map.keys.map { |k| k[0] }.max
  min_y = map.keys.map { |k| k[1] }.min
  max_y = map.keys.map { |k| k[1] }.max

  output = Hash.new('.')

  ((min_y-2)..(max_y+2)).each do |y|
    ((min_x-2)..(max_x+2)).each do |x|
      print map[[x,y]]
    end
    print "\n"
  end
end

def compute_p1(input)
  enhancement = input.lines.first.chomp

  map = Hash.new('.')
  row, col = 0, 0

  input.lines[2..].each do |line|
    line.chomp.chars.each do |c|
      map[[col, row]] = c
      col += 1
    end
    row += 1; col = 0
  end

  step_one = enhance_map(map, enhancement)
  step_two = enhance_map(step_one, enhancement)

  step_two.values.tally['#']
end

def compute_p2(input)
  enhancement = input.lines.first.chomp

  map = Hash.new('.')
  row, col = 0, 0

  input.lines[2..].each do |line|
    line.chomp.chars.each do |c|
      map[[col, row]] = c
      col += 1
    end
    row += 1; col = 0
  end

  50.times do
    map = enhance_map(map, enhancement)
  end

  map.values.tally['#']
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
