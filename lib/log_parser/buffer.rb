# frozen_string_literal: true

module LogParser
  # Log buffers provide line after line from a given source,
  # and only store as many lines as necessary:
  #
  #  * Read lines from `log` lazily, i.e. only if {find_index} or {[]} are called.
  #  * Drop lines that are no longer needed, i.e. when {forward} is called.
  class Buffer
    # Creates a new buffer that reads lines from the given source.
    #
    # @param [Array<String>,IO,StringIO] log
    #   Where to read log lines from. Can be either an array of `String`,
    #   an `IO` (e.g. `STDIN`), or a `StringIO`.
    def initialize(log)
      @buffer = []
      @stream = nil

      @buffer = log if log.is_a?(Array)
      @stream = log if log.is_a?(IO) || log.is_a?(StringIO)
    end

    # Determines whether there are more lines in this log (buffer).
    #
    # @return [true,false]
    def empty?
      @buffer.empty? && stream_is_done?
    end

    # The current size of this buffer, that is the number of lines currently stored.
    #
    # @return [Integer]
    def buffer_size
      @buffer.size
    end

    # The first available line, if any.
    #
    # _Note:_ Will read from the source if necessary.
    #
    # @return [String,nil]
    def first
      self[0]
    end

    # Finds the first index of an element that fulfills a predicate.
    #
    # @param [Integer] starting_from
    #   The first index to check. That is, indices `(0..starting_from - 1)` are skipped.
    #   *Note:* Indices are relative to the start of the buffer, _not_ the start of the log!
    #
    # @yield Invokes a block as predicate over lines.
    # @yieldparam [String] line
    #   A line of the log.
    # @yieldreturn [true,false]
    #   `true` if (and only if) `line` fulfills the predicate.
    #
    # @return [Integer, nil]
    #   The first index of an element that fulfills the predicate, if any;
    #   otherwise, `nil`.
    def find_index(starting_from = 0)
      index = starting_from
      element = self[index]

      until element.nil?
        return index if yield(element)
        index += 1
        element = self[index]
      end

      nil
    end

    # Retrieves the next `length` many log lines starting from index `offset`.
    #
    # @param [Integer] offset
    #   The first index to retrieve.
    #   *Note:* Indices are relative to the start of the buffer, _not_ the start of the log!
    # @param [Integer] length
    #   The number of elements to retrieve.
    # @return [String,Array<String>]
    #   If `length` is set, returns the array of lines with indices in `(offset..offset+length-1)`.
    #   Otherwise, returns the line with index `offset`.
    def [](offset, length = nil)
      base_length = length || 1
      while offset + base_length > @buffer.size
        return (length.nil? ? nil : @buffer[offset, @buffer.size]) if stream_is_done?
        @buffer.push(@stream.readline.rstrip)
      end

      length.nil? ? @buffer[offset] : @buffer[offset, length]
    end

    # Moves the front of this buffer forwards by `offset` elements.
    #
    # That is, the following code returns `true`:
    # ```ruby
    # before = buffer[offset]
    # buffer.forward[offset]
    # after = buffer.first
    # before == after
    # ```
    #
    # @param [Integer] offset
    #   The number of lines to drop.
    # @return [void]
    def forward(offset = 1)
      self[offset]
      @buffer.slice!(0, offset)
    end

    # Closes the `IO` this buffer reads from, if any.
    #
    # @return [void]
    def close
      @stream.close unless @stream.nil? || @stream.closed?
    end

    private

    # False if (and only if) this buffer reads from an `IO`,
    # that `IO` is not closed, and has not yet reached the end.
    #
    # @return [true,false]
    def stream_is_done?
      @stream.nil? || @stream.closed? || @stream.eof?
    end
  end
end