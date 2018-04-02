# TODO: document
module LogParser
  def initialize
    @files = []
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
  # @param [Array<String>] log_lines
  # @return [Array<LogMessage>]
  def parse(log_lines)
    messages = []

    log_line_number = 1
    until log_lines.empty?
      line = log_lines.first

      if line.strip.empty?
        consumed_lines = 1
      else
        # Use the first pattern that matches. Let's hope that's a good heuristic.
        # If not, we'll have to let all competitors consume and see who wins --
        # which we'd decide how?
        matching_pattern = patterns.detect { |p| p.begins_at?(line) }

        if matching_pattern.nil?
          # In the hope that scope changes happen not on the same
          # line as messages. Gulp.
          scope_changes(log_lines.first).each { |op|
            if op == :pop
              left = @files.pop
              #puts "Finished file #{left.nil? ? "nil" : left}" # TODO: debug mode
              left
            else
              #puts "Entered file #{op}" # TODO: debug mode
              @files.push(op)
            end
          }

          # Try again with the next line
          consumed_lines = 1
        else
          # Apply the pattern, i.e. read the next message!
          # @type [LogMessage] message
          message, consumed_lines = matching_pattern.read(log_lines)
          message.log_lines = { from: log_line_number,
                                to: log_line_number + consumed_lines - 1 }
          message.source_file ||= @files.last

          messages.push(message)
        end
      end

      # Forward the window
      log_lines.slice!(0, consumed_lines)
      log_line_number += consumed_lines
    end

    #puts "Filestack: #{@files}" # TODO: debug mode
    messages
  end
end