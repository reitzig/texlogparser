# frozen_string_literal: true

# Matches messages of this form:
#
#   Runaway argument?
#   {Test. Also, it contains some \ref {warnings} and \ref {errors} for t\ETC.
class RunawayParameterError
  include RegExpPattern

  def initialize
    super(/^Runaway argument\?/,
          { pattern: ->(_) { /./ }, until: :match, inclusive: true }
    )
  end

  def read(lines)
    # @type [LogMessage] msg
    msg, consumed = super(lines)

    msg.level = :error

    [msg, consumed]
  end
end
