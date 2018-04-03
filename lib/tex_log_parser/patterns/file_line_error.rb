# frozen_string_literal: true

# Matches messages of this form:
#
#   ./plain.tex:31: Undefined control sequence.
#   l.31 ...t contains some \ref{warnings} and \errors
#                                                       for testing.
class FileLineError
  include RegExpPattern

  def initialize
    super(%r{^(/?(?:.*?/)*[^/]+):(\d+):})
  end

  def read(lines)
    # @type [LogMessage] msg
    msg, consumed = super(lines)

    msg.source_file = @start_match[1]
    line = @start_match[2].to_i
    msg.source_lines = { from: line, to: line }
    msg.preformatted = true
    msg.level = :error

    [msg, consumed]
  end
end
