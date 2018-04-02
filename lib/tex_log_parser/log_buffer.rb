class LogBuffer
  # @param [Array<String>,IO] log
  def initialize(log)
    @buffer = []
    @stream = nil

    @buffer = log if log.is_a?(Array)
    @stream = log if log.is_a?(IO) || log.is_a?(StringIO)
  end

  def empty?
    @buffer.empty? && stream_is_done?
  end

  def first
    self[0]
  end

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

  def [](offset, length = nil)
    base_length = length || 1
    while offset + base_length > @buffer.size
      return (length.nil? ? nil : @buffer[offset, @buffer.size]) if stream_is_done?
      @buffer.push(@stream.readline.rstrip)
    end

    length.nil? ? @buffer[offset] : @buffer[offset, length]
  end

  def forward(offset = 1)
    self[offset]
    @buffer.slice!(0, offset)
  end

  def close
    @stream.close unless @stream.nil? || @stream.closed?
  end

  private

  def stream_is_done?
    @stream.nil? || @stream.closed? || @stream.eof?
  end
end