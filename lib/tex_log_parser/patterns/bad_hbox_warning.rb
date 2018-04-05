# frozen_string_literal: true

# TODO: document
class BadHboxWarning
  include RegExpPattern

  def initialize
    super(/^(Over|Under)full \\hbox.*at lines (\d+)--(\d+)/,
          { pattern: ->(_) { /^\s*\[\]\s*$/ }, until: :match, inclusive: false }
    )
  end

  def read(lines)
    # @type [LogMessage] msg
    msg, consumed = super(lines)

    msg.source_lines = { from: @start_match[2].to_i,
                         to: @start_match[3].to_i }
    msg.preformatted = true
    msg.level = :warning

    [msg, consumed]
  end
end
