# frozen_string_literal: true

# A simple helper, probably to be replaced by a proper logging library
# at some point.
#
# @attr [true,false] debug
class Logger
  class << self
    attr_accessor :debugging

    def debug?
      debugging || !ENV['DEBUG'].nil?
    end

    # Logs the given message to STDOUT if `debug` is true.
    # @param [String] message
    def debug(message)
      puts message if debug?
    end
  end
end