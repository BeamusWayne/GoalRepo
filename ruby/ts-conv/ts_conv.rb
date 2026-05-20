#!/usr/bin/env ruby
# frozen_string_literal: true

# Unix timestamp conversion CLI tool.
# Usage:
#   ruby ts_conv.rb 1700000000          # timestamp to human-readable
#   ruby ts_conv.rb "2024-01-15 12:00"  # human-readable to timestamp
#   ruby ts_conv.rb "2 hours ago"       # relative time
#   ruby ts_conv.rb "tomorrow"
#   ruby ts_conv.rb now                 # current time
#   ruby ts_conv.rb -f iso 1700000000   # specify output format

require "time"

module TsConv
  FORMATS = {
    "default" => ->(t) { t.strftime("%Y-%m-%d %H:%M:%S %Z") },
    "iso"     => ->(t) { t.iso8601 },
    "rfc"     => ->(t) { t.rfc2822 },
    "date"    => ->(t) { t.strftime("%Y-%m-%d") },
    "time"    => ->(t) { t.strftime("%H:%M:%S") },
    "unix"    => ->(t) { t.to_i.to_s },
    "ms"      => ->(t) { (t.to_f * 1000).to_i.to_s }
  }.freeze

  module_function

  def parse(input)
    case input.strip
    when /\A\d{10}\z/           then Time.at(input.to_i)
    when /\A\d{13}\z/          then Time.at(input.to_i / 1000.0)
    when /\Anow\z/i            then Time.now
    when /\A(\d+)\s+(s(?:ec|econds?)?)\s+ago\z/i   then Time.now - $1.to_i
    when /\A(\d+)\s+(m(?:in(?:utes?)?)?)\s+ago\z/i  then Time.now - $1.to_i * 60
    when /\A(\d+)\s+(h(?:ours?)?)\s+ago\z/i         then Time.now - $1.to_i * 3600
    when /\A(\d+)\s+(d(?:ays?)?)\s+ago\z/i          then Time.now - $1.to_i * 86400
    when /\A(\d+)\s+(w(?:eeks?)?)\s+ago\z/i         then Time.now - $1.to_i * 604800
    when /\Atomorrow\z/i       then Time.now + 86400
    when /\Ayesterday\z/i      then Time.now - 86400
    else
      begin
        Time.parse(input)
      rescue ArgumentError
        abort "error: cannot parse '#{input}'"
      end
    end
  end

  def format_output(time, fmt)
    formatter = FORMATS[fmt] || FORMATS["default"]
    formatter.call(time)
  end

  def run(args)
    fmt = "default"
    inputs = []

    args.each do |arg|
      if arg == "-f" || arg == "--format"
        fmt = nil
      elsif fmt.nil?
        fmt = arg
      else
        inputs << arg
      end
    end

    abort "usage: ts_conv.rb [-f FORMAT] INPUT..." if inputs.empty?

    inputs.each do |input|
      time = parse(input)
      puts "#{format_output(time, fmt)}  (#{time.to_i})"
    end
  rescue => e
    abort "error: #{e.message}"
  end
end

TsConv.run(ARGV) if __FILE__ == $PROGRAM_NAME
