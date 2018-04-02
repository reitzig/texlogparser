require 'minitest/autorun'
require 'tex_log_parser/log_buffer'

require "#{__dir__}/test_logbufferarray"

class LogBufferStreamTests < LogBufferArrayTests
  def log(*elements)
    StringIO.open(elements.join("\n"))
  end
end