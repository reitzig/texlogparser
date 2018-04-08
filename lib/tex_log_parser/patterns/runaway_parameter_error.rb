# frozen_string_literal: true

class TexLogParser
  # Matches messages of this form:
  #
  #     Runaway argument?
  #     {Test. Also, it contains some \ref {warnings} and \ref {errors} for t\ETC.
  class RunawayParameterError
    include LogParser::RegExpPattern

    # Creates a new instance.
    def initialize
      super(/^Runaway argument\?/,
            { pattern: ->(_) { /./ }, until: :match, inclusive: true }
      )
    end

    # (see LogParser::RegExpPattern#read)
    def read(lines)
      # @type [Message] msg
      msg, consumed = super(lines)

      msg.level = :error

      [msg, consumed]
    end
  end
end