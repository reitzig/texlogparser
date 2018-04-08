# frozen_string_literal: true

class TexLogParser
  # TODO: document
  class BadHboxWarning
    include LogParser::RegExpPattern

    # Creates a new instance.
    def initialize
      super(/^(Over|Under)full \\hbox.*at lines (\d+)--(\d+)/,
            { pattern: ->(_) { /^\s*\[\]\s*$/ }, until: :match, inclusive: false }
      )
    end

    # (see LogParser::RegExpPattern#read)
    def read(lines)
      # @type [Message] msg
      msg, consumed = super(lines)

      msg.source_lines = { from: @start_match[2].to_i,
                           to: @start_match[3].to_i }
      msg.preformatted = true
      msg.level = :warning

      [msg, consumed]
    end
  end
end
