# frozen_string_literal: true

class TexLogParser
  # Matches messages of this form:
  #
  #     !  ==> Fatal error occurred, no output PDF file produced!
  #     Transcript written on plain.log.
  class FatalErrorOccurred
    include LogParser::RegExpPattern

    # Creates a new instance.
    def initialize
      super(/^!\s+==>/,
            { pattern: ->(_) { /Transcript written/ }, until: :match, inclusive: true }
      )
    end

    # (see LogParser::RegExpPattern#read)
    def read(lines)
      # @type [Message] msg
      msg, consumed = super(lines)

      msg.level = :error
      msg.preformatted = false

      [msg, consumed]
    end
  end
end