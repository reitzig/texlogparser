# frozen_string_literal: true

require 'minitest/autorun'
require 'json-schema'
require 'tex_log_parser'

# Tests whether {LogParser::Buffer} works correctly when reading from arrays.
class JsonLogTests < Minitest::Test
  def initialize(param)
    super(param)

    schema = "#{File.expand_path(__dir__)}/../resources/message.schema.json"
    @schema = File.read(schema)
  end

  def test_schema_valid
    meta_schema = JSON::Validator.validator_for_uri('http://json-schema.org/draft-06/schema#').metaschema
    errors = JSON::Validator.fully_validate(meta_schema, @schema)
    errors.each { |e| puts e.to_s }
    assert(errors.empty?, 'We should have a valid schema.')
  end

  def test_validity_against_schema
    Dir["#{File.expand_path(__dir__)}/texlogs/*.log"].each do |log|
      LogParser::Logger.debug "\n\nValidating #{log}"
      json = JSON.pretty_generate(TexLogParser.new(File.open(log, 'r')).parse)
      LogParser::Logger.debug json
      errors = JSON::Validator.fully_validate(@schema, json)
      errors.each { |e| puts e.to_s }
      assert(errors.empty?, "JSON output of parsed '#{log}' should be valid.")
    end
  end
end