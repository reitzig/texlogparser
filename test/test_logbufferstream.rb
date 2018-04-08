# frozen_string_literal: true

require 'minitest/autorun'
require 'log_parser/buffer'

require "#{__dir__}/test_logbufferarray"

# Tests whether {LogParser::Buffer} works correctly when reading from `IO`s.
class LogBufferStreamTests < LogBufferArrayTests
  def debug(*elements)
    StringIO.open(elements.join("\n"))
  end
end
