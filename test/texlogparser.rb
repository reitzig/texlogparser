require 'texlogparser'

path = "#{File.expand_path(__dir__)}/texlogs"

test_cases = [
  { file: '000.log', expected: { error: 0, warning: 0, info: 0 } }
]

parser = TeXLogParser.new
test_cases.each do |test|
  messages = parser.parse(File.open("#{path}/#{test[:file]}"))

  counts = { error: 0, warning: 0, info: 0 }
  messages.each { |m| counts[m.level] += 1 }

  if counts == test[:expected]
    puts "OK"
  else
    puts "FAIL"
    puts "\tExpected:\t#{test[:expected]}"
    puts "\tActual:\t#{counts}"
  end
end