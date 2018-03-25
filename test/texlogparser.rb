require 'minitest/autorun'
require 'texlogparser'

class TeXLogParserTests < Minitest::Test
  def generic_test(file, expected)
    parser = TeXLogParser.new
    path = "#{File.expand_path(__dir__)}/texlogs"

    messages = parser.parse(File.open("#{path}/#{file}", &:readlines))

    counts = { error: 0, warning: 0, info: 0 }
    messages.each { |m|
      #puts m
      counts[m.level] += 1
    }

    assert_equal(expected, counts, "Wrong counts when parsing '#{file}'")
  end

  def test_000
    generic_test('000.log', { error: 2, warning: 2, info: 68 })
  end
end