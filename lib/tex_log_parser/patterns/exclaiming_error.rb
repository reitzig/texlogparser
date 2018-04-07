# frozen_string_literal: true

# Matches messages of this form:
#
#   ! File ended while scanning use of \@footnotetext.
#   <inserted text>
#                   \par
#   <*> plain.tex
class ExclaimingError
  include RegExpPattern

  def initialize
    super(/^\! \w+/,
          { pattern: ->(_) { /^\s*<\*>\s+([^\s]+)/ }, until: :match, inclusive: true }
    )
  end

  def read(lines)
    # @type [LogMessage] msg
    msg, consumed = super(lines)

    msg.level = :error
    # Remove last line
    msg.message.gsub!(@ending[:pattern][nil], '')
    msg.message.rstrip!

    msg.source_file = @end_match[1]
    msg.preformatted = true

    [msg, consumed]
  end
end
