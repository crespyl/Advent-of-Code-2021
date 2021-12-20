#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'

require 'set'
require 'pqueue'

require '../util/grid'

TEST_STR = "\
--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-14
"

class Test < MiniTest::Test
  def test_p1
    assert_equal(79, compute_p1(TEST_STR))
  end

  # def test_p2
  #   assert_equal(112, compute_p2(TEST_STR))
  # end
end

def dist3d(a, b)
  Math.sqrt((b[0] - a[0])**2 + (b[1] - a[1])**2 + (b[2] - a[2])**2)
end

def beacon_triangles(beacons)
  beacons.combination(3).map do |a, b, c|
    ab = dist3d(a, b)
    bc = dist3d(b, c)
    ca = dist3d(c, a)
    [[ab, bc, ca].sort, Set.new([a, b, c])]
  end.to_h
end

def beacon_transformations(beacon)
  transforms = [] # list of [beacon, ['rotation', inversion]] pairs

  rotations  = [0,1,2].permutation(3).to_a
  inversions = [[1,1,1], [1,1,-1], [1,-1,1], [-1,1,1], [1,-1,-1], [-1,1,-1], [-1,-1,1], [-1,-1,-1]]

  rotations.each do |r|
    inversions.each do |i|
      transformed = [beacon[r[0]] * i[0], beacon[r[1]] * i[1], beacon[r[2]] * i[2]]
      transforms << [transformed, [r, i]]
    end
  end

  transforms
end

def relative_scanner_position(triangles_a, triangles_b)
  intersection = triangles_a.keys.to_set.intersection(triangles_b.keys.to_set).to_a
  return nil if intersection.empty?

  candidates = Hash.new(0)

  until intersection.empty?
    t = intersection.shift

    ta = triangles_a[t].to_a
    tb = triangles_b[t].to_a

    # for each beacon in triangle_b, try every transform and check the computed difference to each beacon in triangle_a
    tb.each_with_index do |tb_beacon, i|
      transforms = beacon_transformations(tb_beacon)
      transforms.each do |pos, ri| # transformed beacon pos, [rotation, inversion]
        c = [ta[i][0] - pos[0], ta[i][1] - pos[1], ta[i][2] - pos[2]]
        candidates[[c, ri]] += 1
      end
    end
  end

  # returns [scanner_position, [rotation, inversion]]
  candidates.invert[candidates.values.max]
end

def transform_scan(transform, scan)
  rotation, inversion = transform
  scan.map do |beacon|
    [beacon[rotation[0]] * inversion[0],
     beacon[rotation[1]] * inversion[1],
     beacon[rotation[2]] * inversion[2]]
  end
end

def offset_scan(offset, scan)
  scan.map do |beacon|
    [beacon[0] + offset[0],
     beacon[1] + offset[1],
     beacon[2] + offset[2]]
  end
end

# [offset, [rotation, inversion]]
def apply_relative_position(relative_position, scan)
  offset_scan(relative_position[0], transform_scan(relative_position[1], scan))
end

def triangles_overlap?(triangles_a, triangles_b)
  intersection = triangles_a.keys.to_set.intersection(triangles_b.keys.to_set)
  intersection.size >= 220
end

# takes position+transform pairs eg a=[pos, [rotation, inversion]]
def resolve_relative_positions(a, b)
  pos_a = a[0]
  inv_a = a[1][1]

  pos_b = b[0]
  inv_b = b[1][1]

  [pos_a[0] + pos_b[0] * inv_a[0],
   pos_a[1] + pos_b[1] * inv_a[1],
   pos_a[2] + pos_b[2] * inv_a[2]]
end

def compute_p1(input)
  scans = input.split(/--- scanner (\d+) ---/)[1..].each_slice(2).map { |n, s|
    scanner_idx = n.to_i
    reports = s.lines.map(&:chomp).reject(&:empty?).map { _1.split(',').map(&:to_i) }
    [scanner_idx, reports]
  }.to_h

  known_beacons = scans[0].to_set

  puts "triangulating..."
  triangulated_scans = scans.map { |id,scan| {id: id, triangles: beacon_triangles(scan)} }
  puts "done triangulating"

  scanner_positions = { 0 => [0,0,0] }
  scanner_transforms = { 0 => [[0,1,2], [1,1,1]] }

  puts "computing relative positions..."
  relative_positions_a = triangulated_scans.combination(2)
                         .filter { |a,b| triangles_overlap?(a[:triangles], b[:triangles]) }
                         .map { |a,b| [[a[:id], b[:id]], relative_scanner_position(a[:triangles], b[:triangles])] }
  puts "..."
  relative_positions_b = triangulated_scans.combination(2)
                         .filter { |a,b| triangles_overlap?(a[:triangles], b[:triangles]) }
                         .map { |b,a| [[a[:id], b[:id]], relative_scanner_position(a[:triangles], b[:triangles])] }
  relative_positions = (relative_positions_a + relative_positions_b).to_h
  puts "done computing relative positions"

  puts "resolving relative positions"
  until scanner_positions.size == scans.size
    relative_positions.filter { |k,v| k[0] == 0 }.each do |ids, pos_transform|
      scanner_positions[ids[1]] = pos_transform.first
      scanner_transforms[ids[1]] = pos_transform.last
      puts "Found position for scanner #{ids[1]}: #{pos_transform.first}"
      puts "                 transform #{ids[1]}: #{pos_transform.last}"
    end

    todo = relative_positions
             .keys
             .filter { |k| scanner_positions.keys.include?(k[0]) && ! scanner_positions.keys.include?(k[1]) }
             .first
    break if todo.nil?

    known_scanner_id = todo[0]
    unknown_scanner_id = todo[1]

    known_pos = scanner_positions[known_scanner_id]
    known_rot, known_inv = scanner_transforms[known_scanner_id]

    unknown_pos = relative_positions[todo][0]
    unknown_rot, unknown_inv = relative_positions[todo][1]

    relative_positions[[0, unknown_scanner_id]] =
      [
        [
          known_pos[0] + unknown_pos[known_rot[0]] * known_inv[known_rot[0]],
          known_pos[1] + unknown_pos[known_rot[1]] * known_inv[known_rot[1]],
          known_pos[2] + unknown_pos[known_rot[2]] * known_inv[known_rot[2]]
        ],
        [
          [unknown_rot[known_rot[0]], unknown_rot[known_rot[1]], unknown_rot[known_rot[2]]],
          [unknown_inv[0] * known_inv[0], unknown_inv[1] * known_inv[1], unknown_inv[2] * known_inv[2]]
        ]
      ]
  end
  puts "done resolving relative positions"

  # resolve scans
  resolved_scans = {0 => scans[0].to_set}
  (1...scans.size).each do |i|
    resolved_scans[i] = apply_relative_position(relative_positions[[0,i]], scans[i]).to_set
  end

  all_resolved = resolved_scans.values.inject(&:+)

  binding.pry

  all_resolved.size - 12
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
