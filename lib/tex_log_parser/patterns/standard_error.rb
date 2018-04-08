# frozen_string_literal: true

class TexLogParser
  # Matches messages of this form:
  #
  #     ! File ended while scanning use of \@footnotetext.
  #     <inserted text>
  #                     \par
  #     <*> plain.tex
  #
  # and
  #
  #     ! Font TU/NoSuchFont(0)/m/n/9=NoSuchFont at 9.0pt not loadable: Metric (TFM) fi
  #     le or installed font not found.
  #     <to be read again>
  #                      relax
  #     l.40 \end{document}
  class StandardError
    include LogParser::RegExpPattern

    # Creates a new instance.
    def initialize
      super(/^! \w+/,
            { pattern: ->(_) { /^\s*<\*>\s+([^\s]+)|^l\.(\d+)\s+/ }, until: :match, inclusive: true }
      )
    end

    # (see LogParser::RegExpPattern#read)
    def read(lines)
      # @type [Message] msg
      msg, consumed = super(lines)

      msg.level = :error
      # Remove last line
      msg.message.gsub!(@ending[:pattern][nil], '')
      msg.message.rstrip!

      file = @end_match[1]
      line = @end_match[2].to_i

      msg.source_file = file unless file.nil?
      msg.source_lines = { from: line, to: line } unless line.nil? || line.zero?
      msg.preformatted = true

      [msg, consumed]
    end
  end
end