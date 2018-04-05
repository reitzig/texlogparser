# frozen_string_literal: true

require 'logger'
require 'tex_log_parser/log_buffer'
require 'tex_log_parser/log_message'
require 'tex_log_parser/log_parser'
require 'tex_log_parser/log_pattern'
Dir["#{File.expand_path(__dir__)}/tex_log_parser/patterns/*.rb"].each { |p| require p }

# TODO: document
class TexLogParser
  include LogParser

  def patterns
    [FileLineError.new,
     PrefixedMultiLinePattern.new,
     BadHboxWarning.new]
  end

  def scope_changes(line)
    case line
    when /^\s*\(([^()]*)\)\s+(.*)$/
      # A scope opened and closed immediately -- log it, then
      # continue with rest of the line (there can be multiple such
      # things in one line, see e.g. 000.log:656)
      [Regexp.last_match(1), :pop] + (Regexp.last_match(2).strip.empty? ? [] : scope_changes(Regexp.last_match(2)))
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
      ['dummy'] # Compensate the bad pop that will happen next line.
    else
      []
    end
  end
end
