# frozen_string_literal: true

module LogParser
  # Represents a certain pattern log message. The model we use is that
  #  * a pattern tells you if a message starts in a given line, and
  #  * reads lines from there on until it ends.
  # The result will be a {Message}.
  module Pattern
    # Checks if this message pattern matches the given line.
    #
    # @abstract
    # @param [String] _line
    #   The log line currently under investigation.
    # @return [true,false]
    #   `true` if (and only if) this pattern can parse a single message from the given line onwards.
    def begins_at?(_line)
      raise NotImplementedError
    end

    # Reads a message from the given lines.
    #
    # @abstract
    # @param [LogParser::Buffer] _lines
    #   A source of log lines to read from.
    # @return [Array<(Message, Int)>]
    #   An array of the message that was read, and the number of lines that it spans.
    # @raise
    #   If no message end could be found among the given lines.
    def read(_lines)
      raise NotImplementedError
    end
  end

  # (see Pattern)
  #
  # This type of pattern is characterized mainly by two regular expressions:
  #  * One for matching the first line of a message, and
  #  * one for matching the last line (+- 1) of a message, which may depend on the first.
  #
  # @attr [Regexp] start
  #   Used to determine where a message starts.
  #   @see begins_at?
  #   @see initialize
  # @attr [MatchData] start_match
  #   While a message is being processed, this attribute holds the match from the first line.
  # @attr [Regexp] ending
  #   Used to determine where a message ends.
  #   @see ends_at?
  #   @see initialize
  module RegExpPattern
    include Pattern

    # Creates a new instance.
    #
    # @param [Regexp] start
    #   Used to determine where a message starts.
    #   See also {begins_at?}.
    # @param [Hash] ending
    #   Used to determine where a message ends.
    #   See also {ends_at?}.
    # @option ending [Regexp] :pattern
    #   Describes either what all lines of a message look like, or matches the first line not part of the same message.
    # @option ending [:match,:mismatch] :until
    #   Determines what is matched against `:pattern`.
    #    * If `:match`, messages end at the first line that _matches_ `:pattern`.
    #    * If `:mismatch`, messages end at the first line that does _not_ match `:pattern`.
    # @option ending [true,false] :inclusive
    #   Determines whether the first line that (mis)matched `:pattern` should be part of the message.
    def initialize(start, ending = { pattern: ->(_) { /^\s*$/ },
                                     until: :match,
                                     inclusive: false })
      @start = start
      @ending = ending
    end

    # Checks if this message pattern matches the given line,
    # that is whether the `start` regexp (see {initialize}) matches it.
    #
    # @param [String] line
    #   The log line currently under investigation.
    # @return [true,false]
    #   `true` if (and only if) this pattern can parse a single message from the given line onwards.
    def begins_at?(line)
      match = @start.match(line)
      @start_match = match unless match.nil?
      !match.nil?
    end

    # Reads a message from the given lines.
    #
    # @param [LogParser::Buffer] lines
    #   A source of log lines to read from.
    # @return [Array<(Message, Int)>]
    #   An array of the message that was read, and the number of lines that it spans.
    # @raise
    #   If no message end could be found among the given lines.
    def read(lines)
      ending = lines.find_index(1) { |l| ends_at?(l) }
      raise "Did not find end of message (pattern '#{self.class}')." if ending.nil?
      ending -= 1 unless @ending[:inclusive]

      # Use ending+1 since ending is the index when we drop the first line!
      msg = LogParser::Message.new(message: lines[0, ending + 1].join("\n"),
                                   preformatted: true, level: nil,
                                   pattern: self.class)
      [msg, ending + 1]
    end

    protected

    # Checks if the currently read message ends at the given line,
    # that is whether the `ending[:pattern]` regexp (see {initialize}) matches it.
    #
    # @param [String] line
    #   The log line currently under investigation.
    # @return [true,false]
    #   `true` if (and only if) the currently read message ends at the given line.
    def ends_at?(line)
      match = @ending[:pattern][@start_match].match(line)
      @end_match = match unless match.nil?
      !match.nil? == (@ending[:until] == :match)
    end
  end
end
