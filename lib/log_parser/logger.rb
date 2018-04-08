# frozen_string_literal: true

module LogParser
  # A simple helper, probably to be replaced by a proper logging library
  # at some point.
  class Logger
    class << self
      @debugging = false

      # Switches debugging mode on and off.
      #
      # @param [true,false] flag
      # @return [void]
      def debug=(flag)
        @debugging = flag
      end

      # Indicates whether we are debugging.
      #
      # @return [true,false]
      #   `true` if we are in debugging mode, `false` otherwise.
      def debug?
        @debugging || !ENV['DEBUG'].nil?
      end

      # Logs the given message to STDOUT if `debug?` is true.
      #
      # @param [String] message
      # @return [void]
      def debug(message)
        puts message if debug?
      end
    end
  end
end