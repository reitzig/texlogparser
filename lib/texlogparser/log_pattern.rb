# TODO: Document
module LogPattern
  # TODO: Document
  # @param [String] line
  # @return [true,false]
  def begins_at?(line)
    raise NotImplementedError
  end

  # TODO: Document
  # @param [Array<String>] lines
  # @return [Array<(LogMessage, Int)>]
  def read(lines)
    raise NotImplementedError
  end
end

# TODO: document
# @attr [Regexp] start
# @attr [Regexp] ending
module RegExpPattern
  include LogPattern

  # @param [Regexp] start
  # @param [Regexp] ending
  def initialize(start, ending)
    @start = start
    @ending = ending
  end

  def begins_at?(line)
    !(@start =~ line).nil?
  end
end