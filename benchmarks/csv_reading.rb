#!/usr/bin/env ruby

# Date - 28 june 2016. daru version - 0.1.3.1
# Compare speed of Ruby stdlib CSV and DataFrame.from_csv.

require 'benchmark'
require 'csv'
require 'daru'

csv_contents = File.read(File.join(__dir__, 'TradeoffData.csv'))

long_csv_file = Tempfile.new('long_csv')
long_csv_file.write csv_contents * 999
long_csv_file.close
puts `wc -l #{long_csv_file.path}`

wide_csv_file = Tempfile.new('wide_csv')
csv_contents.split("\n").each { |line|
  wide_csv_file.write(("#{line}," * 999) + "\n")
}
wide_csv_file.close
puts `wc -l #{wide_csv_file.path}`

Benchmark.bm do |x|
  x.report("Ruby CSV (long)") { CSV.read(long_csv_file.path) }
  x.report("Ruby CSV (wide)") { CSV.read(wide_csv_file.path) }

  x.report("Daru CSV (long)") { Daru::DataFrame.from_csv(long_csv_file.path) }
  x.report("Daru CSV (wide)") { Daru::DataFrame.from_csv(wide_csv_file.path) }
end

# FIXME: Improve this. It's 4 times slower than Ruby CSV reading!!

#        user     system      total        real
# Ruby CSV  0.010000   0.000000   0.010000 (  0.002385)
# DataFrame.from_csv  0.000000   0.000000   0.000000 (  0.008225)
