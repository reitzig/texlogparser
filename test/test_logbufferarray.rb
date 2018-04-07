# frozen_string_literal: true

require 'minitest/autorun'
require 'log_parser/buffer'

class LogBufferArrayTests < Minitest::Test
  def debug(*elements)
    elements
  end

  def test_empty
    buff = LogParser::Buffer.new(debug)
    assert(buff.empty?, 'Buffer should be empty')
    buff.close
  end

  def test_notempty
    buff = LogParser::Buffer.new(debug('abc'))
    assert(!buff.empty?, 'Buffer should not be empty')
    buff.close
  end

  def test_first_empty
    buff = LogParser::Buffer.new(debug)
    assert(buff.first.nil?)
    buff.close
  end

  def test_first_content
    buff = LogParser::Buffer.new(debug('abc', 'cde'))
    assert_equal('abc', buff.first)
    buff.close
  end

  def test_subscript_single
    buff = LogParser::Buffer.new(debug('abc', 'cde'))
    assert_equal('abc', buff[0])
    assert_equal('cde', buff[1])
    assert_nil(nil, buff[2])
    buff.close
  end

  def test_subscript_range
    buff = LogParser::Buffer.new(debug('abc', 'cde', 'fgh'))
    assert_equal(['abc'], buff[0, 1])
    assert_equal(%w[abc cde], buff[0, 2])
    assert_equal(%w[cde fgh], buff[1, 2])
    assert_equal(['fgh'], buff[2, 2])
    assert_equal([], buff[3, 2])
    buff.close
  end

  def test_forward
    buff = LogParser::Buffer.new(debug('abc', 'cde', 'fgh'))
    assert_equal('abc', buff.first)
    buff.forward
    assert_equal('cde', buff.first)
    buff.forward
    assert_equal('fgh', buff.first)
    buff.forward
    assert(buff.empty?)
    buff.close
  end

  def test_forward_two
    buff = LogParser::Buffer.new(debug('abc', 'cde', 'fgh'))
    assert_equal('abc', buff.first)
    buff.forward(2)
    assert_equal('fgh', buff.first)
    buff.close
  end

  def test_find_index_success
    buff = LogParser::Buffer.new(debug('abc', 'cde', 'fgh'))
    assert_equal(1, buff.find_index { |e| /d/ =~ e })
    assert_equal(0, buff.find_index { |e| /c/ =~ e })
    assert_equal(1, buff.find_index(1) { |e| /c/ =~ e })
    buff.close
  end

  def test_find_index_fail
    buff = LogParser::Buffer.new(debug('abc', 'cde', 'fgh'))
    assert_nil(buff.find_index { |e| /i/ =~ e })
    buff.close
  end
end
