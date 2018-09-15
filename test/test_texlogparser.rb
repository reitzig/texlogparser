# frozen_string_literal: true

require 'minitest/autorun'
require 'tex_log_parser'

# Verifies that {TexLogParser} processes real logs correctly.
class TexLogParserTests < Minitest::Test
  # Tests `TexLogParser` against log `000*.log`.
  def test_000
    # @type [Array<Message>] messages
    messages = quick_test('000_pdf_fl.log', { error: 2, warning: 2, info: 68 },
                          660 => ['push ./000.toc', 'pop  ./000.toc'],
                          644 => ['push /usr/local/texlive/2016/texmf-dist/tex/latex/hyperref/nameref.sty'],
                          651 => ['pop  /usr/local/texlive/2016/texmf-dist/tex/latex/hyperref/nameref.sty']
                          )

    # ./plain.tex:31: Undefined control sequence.
    verify_message(messages,
                   message: /Undefined control sequence/,
                   source_file: /000\.tex/,
                   source_lines: { from: 31, to: 31 },
                   log_lines: { from: 677, to: 684 },
                   level: :error)

    # LaTeX Warning: Reference `warnings' on page 1 undefined on input line 31.
    verify_message(messages,
                   message: /Reference `warnings' on page 1 undefined/,
                   source_file: /000\.tex/,
                   source_lines: { from: 31, to: 31 },
                   log_lines: { from: 675, to: 675 },
                   level: :warning)
  end

  # Tests `TexLogParser` against log `001*.log`.
  def test_001
    # @type [Array<Message>] messages
    messages = quick_test('001_pdf_fl.log', error: 0, warning: 6, info: 71)

    # Overfull \hbox (77.11191pt too wide) in paragraph at lines 33--34
    verify_message(messages,
                   message: /Overfull \\hbox/,
                   source_file: /001\.tex/,
                   source_lines: { from: 33, to: 34 },
                   log_lines: { from: 684, to: 685 },
                   level: :warning)

    # Underfull \hbox (badness 10000) in paragraph at lines 35--36
    verify_message(messages,
                   message: /Underfull \\hbox/,
                   source_file: /001\.tex/,
                   source_lines: { from: 35, to: 36 },
                   log_lines: { from: 689, to: 689 },
                   level: :warning)
  end

  # Tests `TexLogParser` against log `002*.log`.
  def test_002
    # @type [Array<Message>] messages
    messages = quick_test('002_pdf_fl.log', { error: 4, warning: 0, info: 1 },
                          11 => ['push /usr/local/texlive/2016/texmf-dist/tex/generic/german/ngerman.sty'],
                          12 => ['pop  /usr/local/texlive/2016/texmf-dist/tex/generic/german/ngerman.sty'],
                          44 => ['push /usr/local/texlive/2016/texmf-dist/tex/latex/url/url.sty',
                                 'pop  /usr/local/texlive/2016/texmf-dist/tex/latex/url/url.sty',
                                 'pop  /usr/local/texlive/2016/texmf-dist/tex/latex/hyperref/hyperref.sty'],
                          52 => [],
                          53 => ['pop  /usr/local/texlive/2016/texmf-dist/tex/context/base/mkii/supp-pdf.mkii',
                                 'push /usr/local/texlive/2016/texmf-dist/tex/latex/oberdiek/epstopdf-base.sty'],
                          61 => ['push /usr/local/texlive/2016/texmf-dist/tex/latex/bbold/Ubbold.fd',
                                 'pop  /usr/local/texlive/2016/texmf-dist/tex/latex/bbold/Ubbold.fd',
                                 'pop  ./002.tex']
                          )

    # Runaway argument?
    # {Test. Also, it contains some \ref {warnings} and \ref {errors} for t\ETC.
    verify_message(messages,
                   message: /Runaway argument/,
                   log_lines: { from: 62, to: 63 },
                   level: :error)

    # ! File ended while scanning use of \@footnotetext.
    verify_message(messages,
                   message: /File ended while scanning/,
                   source_file: /002\.tex/,
                   log_lines: { from: 64, to: 67 },
                   level: :error)

    # ! Emergency stop.
    verify_message(messages,
                   message: /Emergency stop/,
                   source_file: /002\.tex/,
                   log_lines: { from: 69, to: 70 },
                   level: :error)

    # !  ==> Fatal error occurred, no output PDF file produced!
    verify_message(messages,
                   message: /no output PDF/,
                   log_lines: { from: 72, to: 73 },
                   level: :error)
  end

  # Tests a variant of log 003.
  #
  # @param [String] suffix
  #   Will parse file `texlogs/003_#{suffix}.log`.
  # @param [Integer] line_offset
  #   Log lines of the variants may be shifted; add `line_offset` to the
  #   hardcoded numbers.
  def multitest_003(suffix, line_offset)
    # @type [Array<Message>] messages
    messages = quick_test("003_#{suffix}.log", { error: 12, warning: 6 },
                          49 + line_offset => ['push /usr/local/texlive/2016/texmf-dist/tex/latex/graphics/graphics.sty'],
                          52 + line_offset => ['push /usr/local/texlive/2016/texmf-dist/tex/latex/graphics/trig.sty'],
                          54 + line_offset => ['pop  /usr/local/texlive/2016/texmf-dist/tex/latex/graphics/trig.sty'],
                          60 + line_offset => ['push /usr/local/texlive/2016/texmf-dist/tex/latex/graphics-def/xetex.def'],
                          61 + line_offset => ['push dummy'], # BROKEN_BY_LINEBREAKS
                          62 + line_offset => ['pop  dummy'],  # BROKEN_BY_LINEBREAKS
                          63 + line_offset => ['pop  /usr/local/texlive/2016/texmf-dist/tex/latex/graphics-def/xetex.def',
                                               'pop  /usr/local/texlive/2016/texmf-dist/tex/latex/graphics/graphics.sty'],
                          66 + line_offset => ['pop  /usr/local/texlive/2016/texmf-dist/tex/latex/graphics/graphicx.sty']
                          )

    # Defining command \setsansfont with sig. 'O{}mO{}' on line 503
    verify_message(messages,
                   message: /Defining command \\setsansfont with sig/,
                   source_file: /fontspec-xetex\.sty/,
                   source_lines: { from: 503, to: 503 },
                   log_lines: { from: 283 + line_offset, to: 287 + line_offset },
                   level: :info)

    # ./plain.tex:5: fontspec error: "font-not-found"
    verify_message(messages,
                   message: /font-not-found/,
                   source_file: /plain\.tex/,
                   source_lines: { from: 5, to: 5 },
                   log_lines: { from: 491 + line_offset, to: 502 + line_offset },
                   level: :error)

    # ./plain.tex:5: Font TU/NoSuchFont(0)/m/n/10=NoSuchFont at 10.0pt not loadable:
    verify_message(messages,
                   message: /Font.*not loadable/,
                   source_file: /plain\.tex/,
                   source_lines: { from: 5, to: 5 },
                   log_lines: { from: 544 + line_offset, to: 548 + line_offset },
                   level: :error)
  end

  # Tests `TexLogParser` against log `003_xe_nfl.log`,
  # i.e. the variant obtained by running `xelatex` with `-no-file-line-error`
  def test_003_xe_nfl
    multitest_003('xe_nfl', 0)
  end

  # Tests `TexLogParser` against log `003_xe_fl.log`.
  # i.e. the variant obtained by running `xelatex` with `-file-line-error`
  def test_003_xe_fl
    multitest_003('xe_fl', 1)
  end

  def test_004_pdf
    # @type [Array<Message>] messages
    messages = quick_test("004_pdf.log", { error: 0, warning: 1 },
                          #47 => ['push ./test.aux', 'pop  ./test.aux', 'pop  ./test.tex'] # TODO do we stand a chance?
    )

    # Underfull \hbox (badness 10000) in paragraph at lines 35--36
    verify_message(messages,
                   message: /Underfull \\hbox/,
                   source_file: /test\.tex/,
                   source_lines: { from: 3, to: 3 },
                   log_lines: { from: 41, to: 42 },
                   level: :warning)
  end

  def test_005_pdf
    # @type [Array<Message>] messages
    messages = quick_test("005_pdf_nfl.log", { error: 1, warning: 1 },
                          20 => ['push ./005.aux', 'pop  ./005.aux', 'pop  ./005.tex']
    )

    # Underfull \hbox (badness 10000) in paragraph at lines 35--36
    verify_message(messages,
                   message: /Underfull \\hbox/,
                   source_file: /005\.tex/,
                   source_lines: { from: 9, to: 10 },
                   log_lines: { from: 12, to: 12 },
                   level: :warning)

    verify_message(messages,
                   message: /Undefined control sequence[\s.]*\\zzz/,
                   source_file: /005\.tex/,
                   source_lines: { from: 12, to: 12 },
                   log_lines: { from: 14, to: 17 },
                   level: :error)
  end

  def test_006_pdf
    # @type [Array<Message>] messages
    messages = quick_test("006_pdf.log", { error: 0, warning: 1, info: 15 })

    verify_message(messages,
                   message: /Orphan on page \d+ \(.*? column\) and widow on page \d+ \(.*? column\)/,
                   source_file: /006\.tex/,
                   log_lines: { from: 230, to: 234 },
                   level: :warning)

    verify_message(messages,
                   message: /Defining command \\WaOignorenext with sig/,
                   source_file: /widows-and-orp/, # BROKEN_BY_LINEBREAKS
                   source_lines: { from: 243, to: 243 },
                   log_lines: { from: 209, to: 213 },
                   level: :info)
  end

  private

  # Reads the given file, parses it and compares the counts
  # per message type with the given counts.
  #
  # In debug mode (cf. {Logger.debug?})
  #
  # If all that works out well, returns the list of messages.
  #
  # @param [String] file
  # @param [Hash<Symbol,Int>] expected
  # @param [Hash<Int,Array<String>>] expected_scope_changes
  # @return [Array<Message>]
  def quick_test(file, expected, expected_scope_changes = {})
    LogParser::Logger.debug "\n\nTesting #{file}"

    path = "#{File.expand_path(__dir__)}/texlogs"
    # @type [LogParser] parser
    parser = TexLogParser.new(File.open("#{path}/#{file}", &:readlines))

    messages = parser.parse

    counts = { error: 0, warning: 0, info: 0 }
    messages.each do |m|
      counts[m.level] += 1
    end

    LogParser::Logger.debug "\nTesting message counts for #{file}"
    expected.each do |type, exp|
      next if exp.nil?
      assert_equal(exp, counts[type],
                   "Wrong number of #{type}s in '#{file}'")
    end

    if LogParser::Logger.debug? && !expected_scope_changes.nil?
      LogParser::Logger.debug "\nTesting scope changes for #{file}"

      expected_scope_changes.each do |line, ops|
        assert_equal(ops, parser.scope_changes_by_line[line],
                     "Bad scope changes in line #{file}:#{line}:")
      end
    end

    messages
  end

  # Asserts equality of `expected` and `actual` iff `expected` is not `nil`.
  # NOP otherwise.
  def assert_equal_if_not_nil(expected, actual, msg = nil)
    assert_equal(expected, actual, msg) unless expected.nil?
  end

  # Asserts that `pattern` matches `string` iff `pattern` is not `nil`.
  # NOP otherwise.
  def assert_match_if_not_nil(pattern, string, msg = nil)
    assert_match(pattern, string, msg) unless pattern.nil?
  end

  # Verifies that the given set of messages contains (at least) one that fits the given parameters.
  #
  # The starting log line `content[:log_lines][:from]` is used for _finding_ the requisite message.
  # When a matching one is found, the other given attributes are checked for equality.
  def verify_message(messages, content = { message: nil, source_file: nil, source_lines: nil,
                                           log_lines: nil, preformatted: nil, level: nil })
    return if content[:log_lines].nil?

    msg = messages.find { |m| m.log_lines[:from] == content[:log_lines][:from] }
    assert(!msg.nil?, "Message at log line #{content[:log_lines][:from]} not picked up")

    assert_equal_if_not_nil(
      content[:log_lines][:to],
      msg.log_lines[:to],
      'End line in log wrong.'
    )

    assert_match_if_not_nil(
      content[:source_file],
      msg.source_file,
      'Source file wrong.'
    )

    unless content[:source_lines].nil?
      assert_equal_if_not_nil(
        content[:source_lines][:from],
        msg.source_lines[:from],
        'Start line in source wrong.'
      )

      assert_equal_if_not_nil(
        content[:source_lines][:to],
        msg.source_lines[:to],
        'End line in source wrong.'
      )
    end

    assert_match_if_not_nil(
      content[:message], msg.message,
      'Message wrong.'
    )

    assert_equal_if_not_nil(
      content[:level],
      msg.level
    )
  end
end

