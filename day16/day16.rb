#!/usr/bin/env ruby

require 'benchmark'
require 'minitest'
require 'pry-byebug'

require 'set'
require 'pqueue'

require '../util/grid'

TEST_STR = "\

"

class Test < MiniTest::Test
  def test_p1
    assert_equal(16, compute_p1("8A004A801A8002F478"))
    assert_equal(12, compute_p1("620080001611562C8802118E34"))
    assert_equal(31, compute_p1("A0016C880162017C3686B18A3D4780"))
  end

  def test_p2
    assert_equal(3,  compute_p2("C200B40A82"))
    assert_equal(54, compute_p2("04005AC33890"))
    assert_equal(1,  compute_p2("9C0141080250320F1802104A08"))
  end
end

# can't just parse with `to_i` because we care about leading 0s
def hex_to_bitstr(hex)
  "%0#{hex.length * 4}b" % hex.to_i(16)
end

def parse_packet_version(bitstr)
  bitstr[0..2].to_i(2)
end

def parse_packet_type(bitstr)
  bitstr[3..5].to_i(2)
end

def parse_literal_groups(bitstr, offset)
  value = ''
  idx = offset
  loop do
    group = bitstr[idx..idx+4]
    value += group[1..]
    idx += 5
    break if group[0] == '0'
  end
  [value.to_i(2), idx-offset]
end

def parse_literal_packet(bitstr, offset)
  ver = parse_packet_version(bitstr[offset..])
  typ = parse_packet_type(bitstr[offset..])
  raise "Tried to parse packet-type #{typ} as literal!" unless typ == 4

  value, value_size = parse_literal_groups(bitstr, offset+6)
  [{version: ver, type: :literal, value: value, size: value_size+6}, value_size+6]
end

def parse_operator_packet(bitstr, offset)
  ver = parse_packet_version(bitstr[offset..])
  typ = parse_packet_type(bitstr[offset..])
  raise "Tried to parse literal packet (#{typ}) as operator!" if typ == 4

  op = case typ
       when 0 then :sum
       when 1 then :product
       when 2 then :minimum
       when 3 then :maximum
       when 5 then :greater_than
       when 6 then :less_than
       when 7 then :equal_to
       end

  base = offset
  offset+=6
  length_mode, length_length = case bitstr[offset]
                               when '0' then [:len_bits, 15]
                               when '1' then [:len_packets, 11]
                               end
  offset+=1

  length = bitstr[offset...offset+length_length].to_i(2)
  offset+=length_length

  packets = case length_mode
            when :len_bits then parse_packets_bits(bitstr, offset, length)
            when :len_packets then parse_packets_count(bitstr, offset, length)
            end
  offset+=packets.map {_1[:size]}.sum

  [{version: ver, type: :operator, op: op, packets: packets, size: offset-base}, offset-base]
end

def parse_packet(bitstr, offset)
  case parse_packet_type(bitstr[offset..])
  when 4
    parse_literal_packet(bitstr, offset)
  else
    parse_operator_packet(bitstr, offset)
  end
end

def parse_packets_bits(bitstr, offset, num_bits)
  packets = []
  while num_bits > 0 && offset < bitstr.length
    packet, size = parse_packet(bitstr, offset)
    packets << packet
    num_bits -= size
    offset += size
  end
  return packets
end

def parse_packets_count(bitstr, offset, num_packets)
  packets = []
  while num_packets > 0 && offset < bitstr.length
    packet, size = parse_packet(bitstr, offset)
    packets << packet
    num_packets -= 1
    offset+=size
  end
  packets
end

def version_sum(packet)
  case packet[:type]
  when :literal then packet[:version]
  when :operator then packet[:version] + packet[:packets].map { version_sum(_1) }.sum
  end
end

def evaluate(packet)
  case packet[:type]
  when :literal then packet[:value]
  when :operator then case packet[:op]
                      when :sum then packet[:packets].map { evaluate(_1) }.inject(&:+)
                      when :product then packet[:packets].map { evaluate(_1) }.inject(&:*)
                      when :minimum then packet[:packets].map { evaluate(_1) }.min
                      when :maximum then packet[:packets].map { evaluate(_1) }.max
                      when :greater_than
                        values = packet[:packets].map { evaluate(_1) }
                        values[0] > values[1] ? 1 : 0
                      when :less_than
                        values = packet[:packets].map { evaluate(_1) }
                        values[0] < values[1] ? 1 : 0
                      when :equal_to
                        values = packet[:packets].map { evaluate(_1) }
                        values[0] == values[1] ? 1 : 0
                      else
                        raise "unknown operator type #{packet[:op]}"
                      end
  end
end

def compute_p1(input)
  packet, _size = parse_packet(hex_to_bitstr(input.chomp), 0)
  version_sum(packet)
end

def compute_p2(input)
  packet, _size = parse_packet(hex_to_bitstr(input.chomp), 0)
  evaluate(packet)
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
