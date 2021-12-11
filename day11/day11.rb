#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'
require 'set'

require '../util/grid'

TEST_STR = "\
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(1656, compute_p1(TEST_STR))
  end

  def test_p2
    assert_equal(195, compute_p2(TEST_STR))
  end
end

def compute_p1(input)
  grid = Grid.new(input)
  grid.update do |_x, _y, value|
    value.to_i
  end

  flashes = 0
  100.times do
    grid.update do |_x, _y, value|
      value + 1
    end

    already_flashed = Set.new

    until (to_flash = grid.coords_where { |value| value > 9 }
                          .to_set - already_flashed
          ).empty?

      x, y = to_flash.first
      already_flashed += [[x, y]]

      [
        [-1, -1], [0, -1], [+1, -1],
        [-1,  0],          [+1, 0],
        [-1, +1], [0, +1], [+1, +1]
      ].map { |dx,dy| [x+dx,y+dy] }
        .each do |nx,ny|
        next unless grid.in_bounds?(nx, ny)

        grid.set(nx, ny, grid.get(nx, ny) + 1)
      end
    end

    already_flashed.each do |x, y|
      grid.set(x, y, 0)
    end

    flashes += already_flashed.count
  end

  return flashes
end

def compute_p2(input)
  grid = Grid.new(input)
  grid.update do |_x, _y, value|
    value.to_i
  end

  cycles = 0
  until grid.all?(grid.get(0, 0))
    grid.update do |_x, _y, value|
      value + 1
    end

    already_flashed = Set.new

    until (to_flash = grid.coords_where { |value| value > 9 }
                        .to_set - already_flashed
          ).empty?

      x, y = to_flash.first
      already_flashed += [[x, y]]

      [
        [-1, -1], [0, -1], [+1, -1],
        [-1,  0],          [+1, 0],
        [-1, +1], [0, +1], [+1, +1]
      ].map { |dx,dy| [x+dx,y+dy] }
        .each do |nx,ny|
        next unless grid.in_bounds?(nx, ny)

        grid.set(nx, ny, grid.get(nx, ny) + 1)
      end
    end

    already_flashed.each do |x,y|
      grid.set(x, y, 0)
    end

    cycles += 1
  end

  return cycles
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
