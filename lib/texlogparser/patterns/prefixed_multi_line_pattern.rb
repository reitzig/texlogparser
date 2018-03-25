require "#{File.expand_path(__dir__)}/../log_pattern"

# Matches messages of this form:
#
#     Package tocbasic Info: omitting babel extension for `toc'
#     (tocbasic)             because of feature `nobabel' available
#     (tocbasic)             for `toc' on input line 132.
class PrefixedMultiLinePattern
  include RegExpPattern

  def initialize
    super(/(Package|Class|LaTeX)\s+(?:(\w+)\s+)?(Warning|Error|Info|Message)/,
          { pattern: ->(m) { /^\s*\(#{m[2]}\)/ },
            until: :mismatch,
            inclusive: false })
  end

  def read(lines)
    # @type [LogMessage] msg
    # @type [Int] consumed
    msg, consumed = super(lines)

    case @start_match[3]
    when 'Error'
      msg.level = :error
    when 'Warning'
      msg.level = :warning
    when 'Info', 'Message'
      msg.level = :info
    else
      # TODO: abort?
      # TODO: debug output
    end

    # source file from scope, parser does it

    suffix_match = /on input line\s+(\d+)(?:\.\s*)?\z/.match(msg.message)
    unless suffix_match.nil?
      line = suffix_match[1]
      msg.source_lines = { from: line, to: line }
    end

    [msg, consumed]
  end
end