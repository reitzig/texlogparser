# frozen_string_literal: true

require 'minitest/autorun'
require 'log_parser/pattern'
require 'log_parser/buffer'
require 'log_parser/message'

# Tests whether the different parameterizations of {LogParser::RegExpPattern} work correctly.
class RegExpPatternTest < Minitest::Test
  def initialize(param)
    super(param)

    @example = <<~LOG
      some
      stuff
      start
      stuff
      more
      stuff
      end
      other
      stuff
      LOG
  end

  def example_buffer
    LogParser::Buffer.new(StringIO.new(@example))
  end

  class ExamplePattern
    include LogParser::RegExpPattern
  end

  # Tests one combination of options.
  #
  # @param [Hash] options
  # @option options [:match,:mismatch] :until
  # @option options [true,false] :inclusive
  # @param [Hash] expected
  # @option expected [String] :next
  #   The first non-message line, i.e. the next in the buffer.
  # @option expected [String] :msg
  #   The message content
  def run_with(options, expected)
    pattern = ExamplePattern.new(/start/, { pattern: ->(_) { /end/ } }.merge(options))
    log = example_buffer
    assert(!pattern.begins_at?(log.first))
    log.forward
    assert(!pattern.begins_at?(log.first))
    log.forward
    assert(pattern.begins_at?(log.first))
    msg, consumed = pattern.read(log)
    log.forward(consumed)

    assert_equal(expected[:next], log.first)
    assert_equal(expected[:msg], msg.message)
    log.close
  end

  def test_match_inclusive
    run_with({ until: :match, inclusive: true },
             next: 'other', msg: "start\nstuff\nmore\nstuff\nend")
  end

  def test_match_exclusive
    run_with({ until: :match, inclusive: false },
             next: 'end', msg: "start\nstuff\nmore\nstuff")
  end

  def test_mismatch_inclusive
    run_with({ until: :mismatch, inclusive: true },
             next: 'more', msg: "start\nstuff")
  end

  def test_mismatch_exclusive
    run_with({ until: :mismatch, inclusive: false },
             next: 'stuff', msg: 'start')
  end
end
