require "#{File.expand_path(__dir__)}/log_buffer.rb"

# TODO: document
module LogParser
  attr_reader :messages

  # TODO: document
  # @param [Array<String>,IO,StringIO] log
  # @param [Hash] options
  def initialize(log, options)
    @files = []

    @messages = []
    @log_line_number = 0
    @lines = LogBuffer.new(log)

    @debug = options.fetch(:debug, false)

    puts "Parsing from '#{log}'" if @debug
  end

  # @return [Array<LogPattern>]
  def patterns
    raise NotImplementedError
  end

  # @param [String] line
  # @return [Array<String,:pop>] A list of new scopes this line enters (strings)
  #                              and leaves (`:pop`).
  #                              Read stack operations from left to right.
  def scope_changes(line)
    raise NotImplementedError
  end

  # TODO: document
  # @return [Array<LogMessage>]
  def parse
    raise 'Parser already ran!' unless @log_line_number.zero?

    @log_line_number = 1
    until @lines.empty?
      line = @lines.first

      if line.strip.empty?
        remove_consumed_lines 1
        next
      end

      puts "\nLine: '#{line.strip}'" if @debug

      # Use the first pattern that matches. Let's hope that's a good heuristic.
      # If not, we'll have to let all competitors consume and see who wins --
      # which we'd decide how?
      matching_pattern = patterns.detect { |p| p.begins_at?(line) }

      if matching_pattern.nil?
        puts '- No pattern matches' if @debug
        apply_scope_changes
      else
        puts "- Matched pattern: '#{matching_pattern.class}'" if @debug
        consume_pattern(matching_pattern)
      end
    end

    puts "\nFiles that did not close: #{@files}" if @debug
    @lines.close
    messages
  end

  private

  def remove_consumed_lines(i)
    @lines.forward(i)
    @log_line_number += i
  end

  def consume_pattern(pattern)
    # Apply the pattern, i.e. read the next message!
    begin
      # @type [LogMessage] message
      message, consumed_lines = pattern.read(@lines)
      message.log_lines = { from: @log_line_number,
                            to: @log_line_number + consumed_lines - 1 }
      message.source_file ||= @files.last

      puts message if @debug
      @messages.push(message)
      remove_consumed_lines consumed_lines
    rescue => e
      puts "#{e}" if @debug
      remove_consumed_lines 1
    end
  end

  def apply_scope_changes
    # In the hope that scope changes happen not on the same
    # line as messages. Gulp.
    scope_changes(@lines.first).each do |op|
      if op == :pop
        left = @files.pop
        puts "- Finished source file: '#{left.nil? ? 'nil' : left}'" if @debug
      else # op is file name
        puts "- Entered source file: '#{op}'" if @debug
        @files.push(op)
      end
    end

    remove_consumed_lines 1
  end
end