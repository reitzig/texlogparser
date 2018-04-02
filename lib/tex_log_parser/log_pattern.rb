require "#{File.expand_path(__dir__)}/log_message.rb"

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
# @attr [MatchData] start_match
# @attr [Regexp] ending
module RegExpPattern
  include LogPattern

  # @param [Regexp] start
  # @param [Hash] ending
  # @option ending [Regexp] :pattern
  # @option ending [:match,:mismatch] :until
  # @option ending [true,false] :inclusive
  def initialize(start, ending = { pattern: ->(_) { /^\s*$/ },
                                   until: :match,
                                   inclusive: false })
    @start = start
    @ending = ending
    @debug = false # TODO: Get the option here
  end

  # TODO: document
  def begins_at?(line)
    match = @start.match(line)
    @start_match = match unless match.nil?
    !match.nil?
  end

  # TODO: document
  def ends_at?(line)
    match = !(@ending[:pattern][@start_match] =~ line).nil?
    match == (@ending[:until] == :match)
  end

  # TODO make failable (e.g. EOF)
  # @param [LogBuffer] lines
  # @return [Array<(LogMessage, Int)>]
  def read(lines)
    raise NotImplementedError if @ending.nil?

    ending = lines.find_index(1) { |l| ends_at?(l) }
    raise "Did not find end of message (pattern '#{self.class}')." if ending.nil?
    ending -= 1 unless @ending[:inclusive]

    # Use ending+1 since ending is the index when we drop the first line!
    msg = LogMessage.new(message: lines[0, ending + 1].join("\n"), preformatted: true, level: nil)
    [msg, ending + 1]
  end
end