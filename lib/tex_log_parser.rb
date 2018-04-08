# frozen_string_literal: true

require 'log_parser/log_parser'
Dir["#{File.expand_path(__dir__)}/tex_log_parser/patterns/*.rb"].each { |p| require p }

# Parses logs (and output) of LaTeX interpreters, e.g. `pdflatex`, `xelatex` and `lualatex`.
# Messages are extracted according to a set of patterns (see below).
#
# Instances are single-use; create a new one for every log and parsing run.
#
# *Note:* Due to shortcomings in the native format of those logs, please be
# aware of these recommendations:
#  - Use `-file-line-error` if possible; it makes for more robust source file and line reporting.
#  - Ask for log lines to be broken as rarely as possible; see e.g. [here](https://tex.stackexchange.com/q/52988/3213).
#     Search the sources for `BROKEN_BY_LINEBREAKS` to find all the nastiness (and potential issues) you can avoid by that.
class TexLogParser
  include LogParser

  # (see LogParser#initialize)
  def initialize(log)
    super(log)

    # BROKEN_BY_LINEBREAKS
    # I'd prefer to have this stateless, but well (see below).
    @pushed_dummy = false
  end

  protected

  # @return [Array<Pattern>]
  #   The set of patterns this parser utilizes to extract messages.
  def patterns
    [HighlightedMessages.new,
     FileLineError.new,
     PrefixedMultiLinePattern.new,
     RunawayParameterError.new,
     StandardError.new,
     FatalErrorOccurred.new,
     BadHboxWarning.new]
  end

  # Extracts scope changes in the form of stack operations from the given line.
  #
  # @param [String] line
  # @return [Array<String,:pop>]
  #   A list of new scopes this line enters (filename strings) and leaves (`:pop`).
  #   Read stack operations from left to right.
  #
  #
  # *Implementation note:* The basic format in LaTeX logs is that
  #  * `(filename` marks the beginning of messages from that file, and
  #  * the matching `)` marks the end.
  # Those nest, of course.
  #
  # This implementation is mainly concerned with hacking around problems of how this format is implemented in the logs.
  #  * Filenames may be broken across lines.
  #  * Opening "tags" may or may not appear on a dedicated line.
  #  * Closing "tags" may or may not appear on a dedicated line.
  #  * Badly line-broken message fragments with parentheses confuse matching heuristics for either.
  # If inopportune line breaks can be avoided, this method is a lot more reliable.
  def scope_changes(line)
    pushed_dummy = false

    result =
      case line
      when /^\s*\(([^()]*)\)\s*(.*)$/
        # A scope opened and closed immediately -- log it, then
        # continue with rest of the line (there can be multiple such
        # things in one line, see e.g. 000.log:656)
        [Regexp.last_match(1), :pop] +
        (Regexp.last_match(2).strip.empty? ? [] : scope_changes(Regexp.last_match(2)))
      when /^\s*\(([^()]+?)\s*$/
        # A scope opened and will be closed later.
        # Happens on a dedicated line
        [Regexp.last_match(1)]
      when /^\s*(\)+)(.*)$/
        # Scopes close on a dedicated line, except if they don't (cf 000.log:624)
        # So we have to continue on the rest of the line. Uh oh.
        ([:pop] * Regexp.last_match(1).length) + scope_changes(Regexp.last_match(2))
      when /\([^)]*$/
        # BROKEN_BY_LINEBREAKS
        # Bad linebreaks can cause trailing ) to spill over. Narf.
        # e.g. 000.log:502-503
        pushed_dummy = true
        ['dummy'] # Compensate the bad pop that will happen next line.
      when /^[^()]*\)/
        # BROKEN_BY_LINEBREAKS
        # Badly broken lines may push ) prefixed by non-whitespace. Narf.
        @pushed_dummy ? [:pop] : []
      else
        []
      end

    @pushed_dummy = pushed_dummy || false
    result
  end
end
