require 'minitest/autorun'
require 'tex_log_parser/log_buffer'

class LogBufferArrayTests < Minitest::Test
  def log(*elements)
    elements
  end

  def test_empty
    buff = LogBuffer.new(log)
    assert(buff.empty?, "Buffer should be empty")
    buff.close
  end

  def test_notempty
    buff = LogBuffer.new(log('abc'))
    assert(!buff.empty?, "Buffer should not be empty")
    buff.close
  end

  def test_first_empty
    buff = LogBuffer.new(log)
    assert(buff.first.nil?)
    buff.close
  end

  def test_first_content
    buff = LogBuffer.new(log("abc", "cde"))
    assert_equal("abc", buff.first)
    buff.close
  end

  def test_subscript_single
    buff = LogBuffer.new(log("abc", "cde"))
    assert_equal("abc", buff[0])
    assert_equal("cde", buff[1])
    assert_nil(nil, buff[2])
    buff.close
  end

  def test_subscript_range
    buff = LogBuffer.new(log("abc", "cde", "fgh"))
    assert_equal(["abc"], buff[0,1])
    assert_equal(["abc", "cde"], buff[0,2])
    assert_equal(["cde", "fgh"], buff[1,2])
    assert_equal(["fgh"], buff[2,2])
    assert_equal([], buff[3,2])
    buff.close
  end

  def test_forward
    buff = LogBuffer.new(log("abc", "cde", "fgh"))
    assert_equal("abc", buff.first)
    buff.forward
    assert_equal("cde", buff.first)
    buff.forward
    assert_equal("fgh", buff.first)
    buff.forward
    assert(buff.empty?)
    buff.close
  end

  def test_forward_two
    buff = LogBuffer.new(log("abc", "cde", "fgh"))
    assert_equal("abc", buff.first)
    buff.forward(2)
    assert_equal("fgh", buff.first)
    buff.close
  end

  def test_find_index_success
    buff = LogBuffer.new(log("abc", "cde", "fgh"))
    assert_equal(1, buff.find_index { |e| /d/ =~ e })
    assert_equal(0, buff.find_index { |e| /c/ =~ e })
    assert_equal(1, buff.find_index(1) { |e| /c/ =~ e })
    buff.close
  end

  def test_find_index_fail
    buff = LogBuffer.new(log("abc", "cde", "fgh"))
    assert_nil( buff.find_index { |e| /i/ =~ e })
    buff.close
  end
end
