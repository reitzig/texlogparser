# frozen_string_literal: true

require 'log_parser/logger'
require 'log_parser/buffer'
require 'log_parser/message'
require 'log_parser/pattern'

# Parses a log, extracting messages according to a set of {Pattern}.
#
# Instances are single-use; create a new one for every log and parsing run.
module LogParser
  # @return [Array<Message>]
  #   the messages this parser found in the given log.
  attr_reader :messages

  # The parser keeps a record of the scope changes it detects.
  #
  # **Note:** Only available in debug mode; see {Logger}.
  #
  # The keys are line indices.
  # The values are arrays of strings, with one string per scope change,
  # in the same order as in the original line.
  #  * Entering a new scope is denoted by
  #
  #     ```
  #     push filename
  #     ```
  #    and
  #  * leaving a scope by
  #
  #     ```
  #     pop  filename
  #     ```
  #     Note the extra space after `pop` here; it's there for quaint cosmetic reasons.
  #
  # @return [Hash<Integer, Array<String>>]
  #   the scope changes this parser detected in the given log.
  attr_reader :scope_changes_by_line if Logger.debug?

  # Parses the given log lines and extracts all messages (of known form).
  # @return [Array<Message>]
  def parse
    skip_empty_lines
    until empty?
      parse_next_lines
      skip_empty_lines
    end

    # TODO: Remove duplicates?
    @messages
  end

  protected

  # Creates a new instance.
  #
  # This parser will read lines one by one from the given `log`.
  # If it is an `IO` or `StringIO`, only those lines currently under investigation will be kept in memory.
  #
  # @param [Array<String>,IO,StringIO] log
  #   A set of log lines that will be parsed.
  def initialize(log)
    @files = []

    @messages = []
    @log_line_number = 1
    @lines = LogParser::Buffer.new(log)

    Logger.debug "Parsing from '#{log}'"
    @scope_changes_by_line = {} if Logger.debug?
  end

  # @abstract
  # @return [Array<Pattern>]
  #   The set of patterns this parser utilizes to extract messages.
  def patterns
    raise NotImplementedError
  end

  # Extracts scope changes in the form of stack operations from the given line.
  #
  # @abstract
  # @param [String] _line
  # @return [Array<String,:pop>]
  #   A list of new scopes this line enters (filename strings) and leaves (`:pop`).
  #   Read stack operations from left to right.
  def scope_changes(_line)
    raise NotImplementedError
  end

  # @return [true,false]
  #   `true` if (and only if) there are no more lines to consume.
  def empty?
    @lines.empty?
  end

  private

  # Forwards the internal buffer up to the next line that contains anything but whitespace.
  #
  # @return [void]
  def skip_empty_lines
    @lines.first

    first_nonempty_line = @lines.find_index { |line| /[^\s]/ =~ line }
    remove_consumed_lines(first_nonempty_line || @lines.buffer_size)
  end

  # Reads the log until the next full message, consuming the lines.
  # Assumes that empty lines have already been skipped.
  #
  # @return [Message,nil]
  #   The next message that could be extracted, or `nil` if none could be found.
  # @raise If parsing already finished.
  def parse_next_lines
    raise 'Parse already done!' if @lines.empty?

    line = @lines.first
    Logger.debug "\nLine #{@log_line_number}: '#{line.strip}'"
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

  # After reading `i` lines, remove them from the internal buffer using this method.
  #
  # @return [void]
  def remove_consumed_lines(i)
    @lines.forward(i)
    @log_line_number += i

    @scope_changes_by_line[@log_line_number] = [] if Logger.debug? && i.positive?
  end

  # Consume as many lines as the given pattern will match.
  # Assumes that `pattern.begins_at?(@lines.first)` is `true`.
  #
  # If applying `pattern` is not successful, this method consumes a single line.
  #
  # @param [Pattern] pattern
  #   The pattern to use for matching.
  # @return [Message,nil]
  #   The message `pattern` produced, if any.
  def consume_pattern(pattern)
    # Apply the pattern, i.e. read the next message!

    # @type [Message] message
    message, consumed_lines = pattern.read(@lines)
    message.log_lines = { from: @log_line_number,
                          to: @log_line_number + consumed_lines - 1 }
    message.source_file ||= @files.last
    message.source_lines ||= { from: nil, to: nil }

    Logger.debug message
    remove_consumed_lines consumed_lines
    return message
  rescue StandardError => e
    Logger.debug e.to_s
    remove_consumed_lines 1
    return nil
  end

  # Extracts the scope changes from the current line and applies them to the file stack `@files`.
  #
  # @return [void]
  def apply_scope_changes
    # In the hope that scope changes happen not on the same
    # line as messages. Gulp.
    scope_changes(@lines.first).each do |op|
      if op == :pop
        left = @files.pop

        Logger.debug "- Finished source file: '#{left.nil? ? 'nil' : left}'"
        @scope_changes_by_line[@log_line_number].push "pop  #{left}" if Logger.debug?
      else # op is file name
        Logger.debug "- Entered source file: '#{op}'"
        @scope_changes_by_line[@log_line_number].push "push #{op}" if Logger.debug?

        @files.push(op)
      end
    end

    remove_consumed_lines 1
  end
end
