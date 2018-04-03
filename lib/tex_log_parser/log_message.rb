# frozen_string_literal: true

require 'json'

# @attr [String] message
# @attr [String,nil] source_file
# @attr [Hash<Symbol, Int>,nil] source_lines
# @attr [Hash<Symbol, Int>,nil] log_lines
# @attr [true,false] preformatted
# @attr [:error,:warning,:info,:debug] level
# @attr [Class] pattern
class LogMessage
  def initialize(message:, source_file: nil, source_lines: nil, log_lines: nil,
                 preformatted: false, level: :info, pattern: nil)
    @message = message
    @source_file = source_file
    @source_lines = source_lines
    @log_lines = log_lines
    @preformatted = preformatted
    @level = level
    @pattern = pattern
  end

  attr_accessor :message, :source_file, :source_lines, :log_lines,
                :preformatted, :level

  def to_s
    lines = if @source_lines.nil?
              ''
            else
              # @type [Hash<Symbol, Int>] @source_lines
              ":#{@source_lines.values.uniq.join('-')}"
            end

    message = @message
    message = message.split("\n").map(&:strip).join(' ') unless @preformatted
    message += "\nLog pattern: '#{@pattern}'" if Logger.debugging

    <<~MSG
      #{@source_file}#{lines}: #{@level.to_s.upcase}
      #{message}
    MSG
  end

  def to_json(_options = {})
    hash = {
      level: @level,
      source_file: @source_file,
      source_lines: @source_lines,
      message: @message,
      log_lines: @log_lines,
      preformatted: @preformatted
    }
    hash[:pattern] = @pattern if Logger.debugging
    JSON.pretty_generate hash
  end
end
