# frozen_string_literal: true

class TexLogParser
  # Matches messages of this form:
  #
  #     Overfull \hbox (68.36201pt too wide) in paragraph at lines 33--34
  #     []\OT1/cmr/m/n/10 Let's try to for-ce an over-full box: []
  #     []
  #
  # and
  #
  #     Underfull \hbox (badness 10000) in paragraph at lines 35--36
  #
  #     []
  class BadHboxWarning
    include LogParser::RegExpPattern

    # Creates a new instance.
    def initialize
      super(/^(Over|Under)full \\hbox.*at line(?:s)? (\d+)(?:--(\d+))?/,
            { pattern: ->(_) { /^\s*(\[\])?\s*$/ }, until: :match, inclusive: false }
      )
    end

    # (see LogParser::RegExpPattern#read)
    def read(lines)
      # @type [Message] msg
      msg, consumed = super(lines)

      from_line = @start_match[2].to_i
      end_line = @start_match[3].nil? ? from_line :  @start_match[3].to_i
      msg.source_lines = { from: from_line, to: end_line }
      msg.preformatted = true
      msg.level = :warning

      [msg, consumed]
    end
  end
end
