
# TODO: document
class TeXLogParser
  include LogParser

  def patterns
    [PackageInfo.new]
  end

  def scope_changes(line)
    [] # TODO: implement
  end
end