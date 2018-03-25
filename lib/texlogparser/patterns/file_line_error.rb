require "#{File.expand_path(__dir__)}/../log_pattern"

# Matches messages of this form:
#
#   ./plain.tex:31: Undefined control sequence.
#   l.31 ...t contains some \ref{warnings} and \errors
#                                                       for testing.
class FileLineError
  include RegExpPattern

  def initialize
    super(/^\/?(?:.*?\/)*[^\/]+:(\d+):/)
  end

  def read(lines)
    # @type [LogMessage] msg
    msg, consumed = super(lines)

    # source file from scope, parser does it

    line = @start_match[1].to_i
    msg.source_lines = { from: line, to: line}
    msg.level = :error

    [msg, consumed]
  end
end