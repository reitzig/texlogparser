require "#{File.expand_path(__dir__)}/../log_pattern"

# Matches messages of this form:
#
#     Package tocbasic Info: omitting babel extension for `toc'
#     (tocbasic)             because of feature `nobabel' available
#     (tocbasic)             for `toc' on input line 132.
#
# Note: currently fails if lines get broken badly, e.g. in 000.log:634.
class PrefixedMultiLinePattern
  include RegExpPattern

  def initialize
    super(/(Package|Class|\w+TeX)\s+(?:(\w+)\s+)?(Warning|Error|Info|Message)/,
          { pattern: ->(m) { /^\s*\(#{m[2]}\)/ }, # BROKEN_BY_LINEBREAKS
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

    # BROKEN_BY_LINEBREAKS
    # TODO: may be split across lines --> remove whitespace before extracting
    suffix_match = /on input line\s+(\d+)(?:\.\s*)?\z/.match(msg.message)
    unless suffix_match.nil?
      line = suffix_match[1].to_i
      msg.source_lines = { from: line, to: line }
    end

    # TODO: message itself contains useless line prefixes --> remove

    [msg, consumed]
  end
end