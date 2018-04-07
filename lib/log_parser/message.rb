# frozen_string_literal: true

require 'json'

module LogParser
  # A single log message.
  #
  # @attr [String] message
  #   The actual message body from the log.
  # @attr [String,nil] source_file
  #   The name of the source file this message originated from.
  #   `nil` if it could not be determined.
  # @attr [Hash<Symbol, Int>,nil] source_lines
  #   A hash with keys `:from` and `:to` mapping to the first and last line index in `source_file` this message pertains to.
  #   `nil` if they could not be determined.
  # @attr [Hash<Symbol, Int>,nil] log_lines
  #   A hash with keys `:from` and `:to` mapping to the first and last line index in the log file that this message covers.
  #   `nil` if they could not be determined.
  # @attr [true,false] preformatted
  #   If `true`, `message` should be printed as-is.
  #   Otherwise, whitespace can be eliminated.
  # @attr [:error,:warning,:info,:debug] level
  #   The severity of this message.
  # @attr [Class] pattern
  #   The {LogParser::Pattern} this message was matched by.
  class Message
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
      message += "\nLog pattern: '#{@pattern}'" if Logger.debug?

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
      hash[:pattern] = @pattern if Logger.debug?
      JSON.pretty_generate hash
    end
  end
end