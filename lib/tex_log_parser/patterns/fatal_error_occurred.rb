# frozen_string_literal: true

# Matches messages of this form:
#
# !  ==> Fatal error occurred, no output PDF file produced!
# Transcript written on plain.log.
class FatalErrorOccurred
  include RegExpPattern

  def initialize
    super(/^\!\s+==>/,
          { pattern: ->(_) { /Transcript written/ }, until: :match, inclusive: true }
    )
  end

  def read(lines)
    # @type [LogMessage] msg
    msg, consumed = super(lines)

    msg.level = :error
    msg.preformatted = false

    [msg, consumed]
  end
end