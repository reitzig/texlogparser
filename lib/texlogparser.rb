require 'texlogparser/log_parser'
Dir["#{File.expand_path(__dir__)}/texlogparser/patterns/*.rb"].each { |p| require p }

# TODO: document
class TeXLogParser
  include LogParser

  def patterns
    [FileLineError.new, PrefixedMultiLinePattern.new]
  end

  def scope_changes(line)
    ops = case line
    when /^\s*\(([^()]*)\)\s+(.*)$/
      # A scope opened and closed immediately -- log it, then
      # continue with rest of the line (there can be multiple such
      # things in one line, see e.g. 000.log:656)
      [$1, :pop] + ($2.strip.empty? ? [] : scope_changes($2))
    when /^\s*\(([^()]+?)\s*$/
      # A scope opened and will be closed later.
      # Happens on a dedicated line
      [$1]
    when /^\s*(\)+)(.*)$/
      # Scopes close on a dedicated line, except if they don't (cf 000.log:624)
      # So we have to continue on the rest of the line. Uh oh.
      ([:pop] * $1.length) + scope_changes($2)
    when /\([^)]*$/
      # Bad linebreaks can cause trailing ) to spill over. Narf.
      # e.g. 000.log:502-503
      ["dummy"] # Compensate the bad pop that will happen next line.
    else
      []
    end

    #puts line # TODO: debug mode
    #puts ops.to_s
    #puts ""
    ops
  end
end