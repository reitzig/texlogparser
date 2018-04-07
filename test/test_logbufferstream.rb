# frozen_string_literal: true

require 'minitest/autorun'
require 'log_parser/buffer'

require "#{__dir__}/test_logbufferarray"

class LogBufferStreamTests < LogBufferArrayTests
  def debug(*elements)
    StringIO.open(elements.join("\n"))
  end
end
