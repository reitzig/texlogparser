# frozen_string_literal: true

# TODO: document
module LogParser
  attr_reader :messages

  # TODO: document
  # @param [Array<String>,IO,StringIO] log
  # @param [Hash] _options
  def initialize(log, _options = {})
    @files = []

    @messages = []
    @log_line_number = 1
    @lines = LogBuffer.new(log)

    Logger.debug "Parsing from '#{log}'"
  end

  # @return [Array<LogPattern>]
  def patterns
    raise NotImplementedError
  end

  # @param [String] _line
  # @return [Array<String,:pop>] A list of new scopes this line enters (strings)
  #                              and leaves (`:pop`).
  #                              Read stack operations from left to right.
  def scope_changes(_line)
    raise NotImplementedError
  end

  def empty?
    @lines.empty?
  end

  # TODO: document
  # @return [Array<LogMessage>]
  def parse
    skip_empty_lines
    until empty?
      parse_next_lines
      skip_empty_lines
    end

    # TODO: Remove duplicates?
    @messages
  end

  private

  def skip_empty_lines
    @lines.first

    first_nonempty_line = @lines.find_index { |line| /[^\s]/ =~ line }
    remove_consumed_lines(first_nonempty_line || @lines.buffer_size)
  end

  # TODO: document
  # @return [LogMessage,nil]
  def parse_next_lines
    raise 'Parse already done!' if @lines.empty?

    line = @lines.first
    Logger.debug "\nLine: '#{line.strip}'"
    msg = nil

    # Use the first pattern that matches. Let's hope that's a good heuristic.
    # If not, we'll have to let all competitors consume and see who wins --
    # which we'd decide how?
    matching_pattern = patterns.detect { |p| p.begins_at?(line) }

    if matching_pattern.nil?
      Logger.debug '- No pattern matches'
      apply_scope_changes
    else
      Logger.debug "- Matched pattern: '#{matching_pattern.class}'"
      msg = consume_pattern(matching_pattern)
      @messages.push(msg) unless msg.nil?
    end

    if @lines.empty?
      @lines.close
      Logger.debug "\nFiles that did not close: #{@files}"
    end

    msg
  end

  def remove_consumed_lines(i)
    @lines.forward(i)
    @log_line_number += i
  end

  # @return [LogMessage,nil]
  def consume_pattern(pattern)
    # Apply the pattern, i.e. read the next message!

    # @type [LogMessage] message
    message, consumed_lines = pattern.read(@lines)
    message.log_lines = { from: @log_line_number,
                          to: @log_line_number + consumed_lines - 1 }
    message.source_file ||= @files.last

    Logger.debug message
    remove_consumed_lines consumed_lines
    return message
  rescue StandardError => e
    Logger.debug e.to_s
    remove_consumed_lines 1
    return nil
  end

  def apply_scope_changes
    # In the hope that scope changes happen not on the same
    # line as messages. Gulp.
    scope_changes(@lines.first).each do |op|
      if op == :pop
        left = @files.pop
        Logger.debug "- Finished source file: '#{left.nil? ? 'nil' : left}'"
      else # op is file name
        Logger.debug "- Entered source file: '#{op}'"
        @files.push(op)
      end
    end

    remove_consumed_lines 1
  end
end
