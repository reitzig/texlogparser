# Matches messages of this form:
#
#     Package tocbasic Info: omitting babel extension for `toc'
#     (tocbasic)             because of feature `nobabel' available
#     (tocbasic)             for `toc' on input line 132.
class PackageInfo < RegExpPattern

  def initialize
    super(/(Package|Class)\s+([\w]+)\s+(Warning|Error|Info)/,
          { pattern: ->(m) { /^\(#{m[2]}\)/ },
            until: :mismatch,
            inclusive: true })
  end

  def read(lines)
    msg, consumed = super(lines)

    case @start_match[2]
    when 'Error'
      msg.type = :error
    when 'Warning'
      msg.type = :warning
    when 'Info'
      msg.type = :info
    else
      # ODO: abort?
    end

    # source file, lines: this came from in some package file, uninteresting

    [msg, consumed]
  end
end