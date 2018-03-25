require 'texlogparser/log_parser'
Dir["#{File.expand_path(__dir__)}/texlogparser/patterns/*.rb"].each { |p| require p }

# TODO: document
class TeXLogParser
  include LogParser

  def patterns
    [FileLineError.new, PrefixedMultiLinePattern.new]
  end

  def scope_changes(line)
    [] # TODO: implement
  end
end