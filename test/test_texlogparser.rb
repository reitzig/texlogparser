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
    parser = TexLogParser.new
    path = "#{File.expand_path(__dir__)}/texlogs"

    messages = parser.parse(File.open("#{path}/#{file}", &:readlines))

    counts = { error: 0, warning: 0, info: 0 }
    messages.each { |m|
      #puts m
      counts[m.level] += 1
    }

    expected.each { |type, exp|
      next if exp.nil?
      assert_equal(exp, counts[type],
                   "Wrong number of #{type.to_s}s in '#{file}'")
    }

    messages
  end

  # TODO: document
  def verify_message(messages, content = { message: nil, source_file: nil, source_lines: nil,
                                           log_lines: nil, preformatted: nil, level: nil})
    return if content[:log_lines].nil?

    msg = messages.find { |m| m.log_lines[:from] == content[:log_lines][:from] }
    assert(!msg.nil?, "Message at log line #{content[:log_lines][:from]} not picked up")

    unless content[:log_lines][:to].nil?
      assert_equal(content[:log_lines][:to], msg.log_lines[:to],
                   'End line in log wrong.')
    end
    unless content[:source_file].nil?
      assert_match(content[:source_file], msg.source_file,
                   'Source file wrong.')
    end
    unless content[:source_lines][:from].nil?
      assert_equal(content[:source_lines][:from], msg.source_lines[:from],
                   'Start line in source wrong.')
    end
    unless content[:source_lines][:to].nil?
      assert_equal(content[:source_lines][:to], msg.source_lines[:to],
                   'End line in spirce wrong.')
    end
    unless content[:message].nil?
      assert_match(content[:message], msg.message,
                   'Message wrong.')
    end
    unless content[:level].nil?
      assert_equal(content[:level], msg.level)
    end
  end

  def test_000
    # @type [Array<LogMessage>] messages
    messages = quick_test('000.log', { error: 2, warning: 2, info: 68 })

    # ./plain.tex:31: Undefined control sequence.
    verify_message(messages, {
        message: /Undefined control sequence/,
        source_file: /plain\.tex/,
        source_lines: { from: 31, to: 31 },
        log_lines: { from: 677, to: 684 },
        level: :error
      })

    # LaTeX Warning: Reference `warnings' on page 1 undefined on input line 31.
    verify_message(messages, {
        message: /Reference `warnings' on page 1 undefined/,
        source_file: /plain\.tex/,
        source_lines: { from: 31, to: 31 },
        log_lines: { from: 675, to: 675 },
        level: :warning
    })
  end
end