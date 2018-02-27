# TODO: document
module LogParser
  @files

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

      matching_pattern = patterns.detect { |p| p.begins_at?(line) }
      if matching_pattern.nil?
        # In the hope that scope changes happen not on the same
        # line as messages. Gulp.
        scope_changes(log_lines.first).each { |op|
          # TODO: debug: print which scope was entered/left
          if op == :pop
            @files.pop
          else
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

      # Forward the window
      log_lines.slice!(0, consumed_lines)
      log_line_number += consumed_lines
    end

    messages
  end
end