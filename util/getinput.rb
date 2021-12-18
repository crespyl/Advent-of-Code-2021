#!/usr/bin/env ruby
#
# Usage: getinput.rb year day
# Needs .env file with session cookie

require 'httparty'

year = ARGV[0] || Time.now.year
day = ARGV[1] || Time.now.day + 1
root = %x( git rev-parse --show-toplevel ).strip
cookie = File.read("#{root}/.env")
url = "https://adventofcode.com/#{year}/day/#{day}/input"

loop do
  response = HTTParty.get(url, headers: { "Cookie" => cookie })
  case response.code
  when 404
    STDERR.puts "not ready yet..."
    sleep 1
  when 200
    puts response.body
    STDERR.puts "got input:"
    if response.body.lines.size > 1
      STDERR.puts response.body.lines[..10]
    else
      STDERR.puts response.body[..20]
    end
    STDERR.puts "..."
    break
  else
    puts "something happened:"
    puts response.code
    puts response.body
    break
  end
end
