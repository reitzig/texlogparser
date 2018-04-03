# frozen_string_literal: true

require 'minitest/autorun'
require 'tex_log_parser'

class TexLogParserTests < Minitest::Test
  # Reads the given file, parses it and compares the counts
  # per message type with the given counts.
  # If all that works out well, returns the list of messages.
  #
  # @param [String] file
  # @param [Hash<Symbol,Int>] expected
  # @return [Array<LogMessage>]
  def quick_test(file, expected)
    path = "#{File.expand_path(__dir__)}/texlogs"
    parser = TexLogParser.new(File.open("#{path}/#{file}", &:readlines))

    messages = parser.parse

    counts = { error: 0, warning: 0, info: 0 }
    messages.each do |m|
      counts[m.level] += 1
    end

    expected.each do |type, exp|
      next if exp.nil?
      assert_equal(exp, counts[type],
                   "Wrong number of #{type}s in '#{file}'")
    end

    messages
  end

  def assert_equal_if_not_nil(expected, actual, msg = nil)
    assert_equal(expected, actual, msg) unless expected.nil?
  end

  def assert_match_if_not_nil(expected, actual, msg = nil)
    assert_match(expected, actual, msg) unless expected.nil?
  end

  def verify_message(messages, content = { message: nil, source_file: nil, source_lines: nil,
                                           log_lines: nil, preformatted: nil, level: nil })
    return if content[:log_lines].nil?

    msg = messages.find { |m| m.log_lines[:from] == content[:log_lines][:from] }
    assert(!msg.nil?, "Message at log line #{content[:log_lines][:from]} not picked up")

    assert_equal_if_not_nil(
      content[:log_lines][:to],
      msg.log_lines[:to],
      'End line in log wrong.'
    )

    assert_match_if_not_nil(
      content[:source_file],
      msg.source_file,
      'Source file wrong.'
    )

    assert_equal_if_not_nil(
      content[:source_lines][:from],
      msg.source_lines[:from],
      'Start line in source wrong.'
    )

    assert_equal_if_not_nil(
      content[:source_lines][:to],
      msg.source_lines[:to],
      'End line in source wrong.'
    )

    assert_match_if_not_nil(
      content[:message], msg.message,
      'Message wrong.'
    )

    assert_equal_if_not_nil(
      content[:level],
      msg.level
    )
  end

  def test_000
    # @type [Array<LogMessage>] messages
    messages = quick_test('000.log', error: 2, warning: 2, info: 68)

    # ./plain.tex:31: Undefined control sequence.
    verify_message(messages,
                   message: /Undefined control sequence/,
                   source_file: /plain\.tex/,
                   source_lines: { from: 31, to: 31 },
                   log_lines: { from: 677, to: 684 },
                   level: :error)

    # LaTeX Warning: Reference `warnings' on page 1 undefined on input line 31.
    verify_message(messages,
                   message: /Reference `warnings' on page 1 undefined/,
                   source_file: /plain\.tex/,
                   source_lines: { from: 31, to: 31 },
                   log_lines: { from: 675, to: 675 },
                   level: :warning)
  end
end
