# frozen_string_literal: true

require 'logger'
require 'log_parser/log_parser'
Dir["#{File.expand_path(__dir__)}/tex_log_parser/patterns/*.rb"].each { |p| require p }

# TODO: document
class TexLogParser
  include LogParser

  def initialize(log, _options = {})
    super(log, _options)

    # BROKEN_BY_LINEBREAKS
    # I'd prefer to have this stateless, but well (see below).
    @pushed_dummy = false
  end

  def patterns
    [HighlightedMessages.new,
     FileLineError.new,
     PrefixedMultiLinePattern.new,
     RunawayParameterError.new,
     StandardError.new,
     FatalErrorOccurred.new,
     BadHboxWarning.new]
  end

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
        [:pop] if @pushed_dummy ? [:pop] : []
      else
        []
      end

    @pushed_dummy = pushed_dummy || false
    result
  end
end
