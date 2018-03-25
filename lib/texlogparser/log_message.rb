# @attr [String] message
# @attr [String,nil] source_file
# @attr [Hash<Symbol, Int>,nil] source_lines
# @attr [Hash<Symbol, Int>,nil] log_lines
# @attr [true,false] preformatted
# @attr [:error,:warning,:info,:debug] level
class LogMessage
  def initialize(message:, source_file: nil, source_lines: nil, log_lines: nil, preformatted: false, level: :info)
    @message = message
    @source_file = source_file
    @source_lines = source_lines
    @log_lines = log_lines
    @preformatted = preformatted
    @level = level
  end

  attr_accessor :message, :source_file, :source_lines, :log_lines,
                :preformatted, :level

  def to_s
    lines = if @source_lines.nil?
              ""
            else
              # @type [Hash<Symbol, Int>] @source_lines
              @source_lines.values.join("-")
            end
    <<~MSG
      #{@source_file}:#{lines} #{@level.to_s.capitalize}
      #{@message}
    MSG
  end
end