# frozen_string_literal: true

class TexLogParser
  # Matches messages as produces by LaTeX 3, i.e. those of these forms:
  #
  #     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #     !
  #     ./plain.tex:5: fontspec error: "font-not-found"
  #     !
  #     ! The font "NoSuchFont" cannot be found.
  #     !
  #     ! See the fontspec documentation for further information.
  #     !
  #     ! For immediate help type H <return>.
  #     !...............................................
  #
  #     l.5 \setmainfont{NoSuchFont}
  #
  # and
  #
  #     !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #     !
  #     ! fontspec error: "font-not-found"
  #     !
  #     ! The font "NoSuchFont" cannot be found.
  #     !
  #     ! See the fontspec documentation for further information.
  #     !
  #     ! For immediate help type H <return>.
  #     !...............................................
  #
  #     l.5 \setmainfont{NoSuchFont}
  #
  # and
  #
  #     .................................................
  #     . LaTeX info: "xparse/define-command"
  #     .
  #     . Defining command \fontspec with sig. 'O{}mO{}' on line 472.
  #     .................................................
  #
  # and
  #
  #     *************************************************
  #     * widows-and-orphans warning: "orphan-widow"
  #     *
  #     * Orphan on page 1 (second column) and widow on page 2 (first column)
  #     *************************************************
  class HighlightedMessages
    include LogParser::RegExpPattern

    # Creates a new instance.
    def initialize
      super(/^(!{3,}|\.{3,}|\*{3,})$/,
            { pattern: lambda { |m|
                         case m[1][0]
                         when '!'
                           /^l\.(\d+)/
                         when '*'
                           /^\*{3,}\s*$/
                         when '.'
                           /^\.{3,}\s*$/
                         else
                           raise("Expected one of `[!.*]` but found: #{m[1][0]}")
                         end
                       },
              until: :match,
              inclusive: true })
    end

    # (see LogParser::RegExpPattern#read)
    def read(lines)
      # @type [Message] msg
      msg, consumed = super(lines)

      is_error = @start_match[1][0] == '!'

      if is_error
        file_line_match = %r{^(/?(?:.*?/)*[^/]+):(\d+):\s*}.match(msg.message)
        line = nil
        if !file_line_match.nil? # if file-line active
          msg.source_file = file_line_match[1]
          line = file_line_match[2].to_i
          msg.message.gsub!(file_line_match[0], '')
        elsif !@end_match[1].nil?
          # No file-line format, so use line number from end match
          line = @end_match[1].to_i
        end
        msg.source_lines = { from: line, to: line } unless line.nil?

        msg.level = :error

        msg.message.gsub!(/^.*?For immediate help type.*$/, '')
        msg.message.gsub!(/^!\.+\s*$/, '')
        msg.message.gsub!(/^l\.\d+\s+.*$/, '')
      else
        # BROKEN_BY_LINEBREAKS
        # TODO: may be split across lines --> remove whitespace before extracting
        line_match = /on line\s+(\d+)\.$/.match(msg.message)
        unless line_match.nil?
          line = line_match[1].to_i
          msg.source_lines = { from: line, to: line }
        end

        msg.level = @start_match[1][0] == '*' ? :warning : :info

        msg.message.gsub!(@end_match[0], '')
      end

      msg.preformatted = true
      msg.message.sub!(@start, '')
      msg.message.gsub!(/^#{Regexp.escape(@start_match[1][0])}\s+/, '')
      msg.message.strip!

      [msg, consumed]
    end
  end
end