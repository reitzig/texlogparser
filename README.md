# TeXLogParser

[![Gem Version](https://badge.fury.io/rb/tex_log_parser.svg)](https://badge.fury.io/rb/tex_log_parser)
[![Yard docs](http://img.shields.io/badge/yard-docs-green.svg)](http://www.rubydoc.info/gems/tex_log_parser/1.0.0) **˙**
[![Maintainability](https://api.codeclimate.com/v1/badges/748992a2c5f6570797d4/maintainability)](https://codeclimate.com/github/reitzig/texlogparser/maintainability) 
[![Test Coverage](https://api.codeclimate.com/v1/badges/748992a2c5f6570797d4/test_coverage)](https://codeclimate.com/github/reitzig/texlogparser/test_coverage) **˙**
[![Circle CI](https://circleci.com/gh/reitzig/texlogparser.svg?style=svg)](https://circleci.com/gh/reitzig/workflows/texlogparser/tree/master)
[![Inline docs](http://inch-ci.org/github/reitzig/texlogparser.svg?branch=master)](http://inch-ci.org/github/reitzig/texlogparser)

This small Ruby gem eases many pains around digesting logs from (La)TeX engines.
Used as a command-line program or library, it converts (La)TeX logs into human-
or machine-readable forms.

_Disclaimer:_ Due to the nature of (La)TeX logs, parsing is inherently heuristic.

## Installation

On any system with working Ruby (≥ 2.3), installation is as simple as this:

```bash
[sudo] gem install tex_log_parser
```

The usual options and, later, update mechanisms of Rubygems apply; 
please refer to their documentation for details.

## Usage

There are two ways to parse logs: with the command-line program and via the underlying Ruby API.

### Command-line Interface

By default, `texlogparser` reads from stdin and writes to stdout. That is, you can use it like so:

```bash
pdflatex -interaction=nonstopmode example.tex | texlogparser
```
    
This adds so little runtime overhead that there are few reasons _not_ to use it. 
Note that the original log file will still be written to `example.log`, 
so no information is lost.

**Important:** Without `nonstopmode`, `pdflatex` et al. stop on errors to interact
with the user; `texlogparser` is not prepared to play the middle man for that and
will block.

You can also read from and/or write to files:

```bash
texlogparser -i example.log                          # From file, to stdout
texlogparser -i example.log -o example.simple.log    # From and to file
cat example.log | texlogparser -o example.simple.log # From stdin, to file
```

If you want to use the output programmatically, you may want to add option `-f json`.
It does just what it sounds like.

### Ruby API

The interface is rather narrow; your main entry point is class 
    [TexLogParser](http://www.rubydoc.info/gems/tex_log_parser/TexLogParser).
Calling `parse` on it will yield a list of 
    [Message](http://www.rubydoc.info/gems/tex_log_parser/LogParser/Message) 
objects.

Here is a minimal yet complete example:

```ruby
require 'tex_log_parser'

log = File.readlines('example.log')
parser = TexLogParser.new(log)
puts parser.parse[0]
```

### Recommendations

Here are some tips on how to generate logs that do not trip up parsing unnecessarily:

 * Use `_latex` option `-file-line-error` to get higher accuracy regarding source files and lines.
 * [Increase the maximum line length](https://tex.stackexchange.com/a/52994/3213) as much as possible
    to improve overall efficacy. Bad linebreaks are 
        [bad](https://github.com/reitzig/texlogparser/search?utf8=%E2%9C%93&q=BROKEN_BY_LINEBREAKS&type=).
 * Avoid parentheses and whitespace in file paths.
 * The shell output of the initial run of `pdflatex` et al. on a new file can 
    contain output of subprograms, and be complicated in other ways as well. 
    It is therefore more robust to use the log file as written to disk, and/or 
    the output resp. log file produced by a subsequent run. 
    (Don't worry, real errors will stick around!) 

## Contributing

For bug reports and feature requests, the usual rules apply: search for 
    [existing issues](https://github.com/reitzig/texlogparser/issues);
join the discussion or
    [create a new one](https://github.com/reitzig/texlogparser/issues/new);
be specific and nice; expect nothing.
    
That aside, there are two groups of experts whose help would be much appreciated:
(La)TeX gourmets and Ruby developers. 

### TeXians

Please report any logs that get parsed wrong, be it because whole messages are not found,
or because not all details are correctly extracted.

Reports that provide the following information will be the most useful:

 1. Full failing log of a minimal example (ideally with source document).
 2. The engine(s) you use, e.g. `pdflatex`, `xelatex`, or `lualatex`.
 3. Expected number of error, warning, and info messages (the latter optional).
 4. Expected message with
    * log line numbers (where the message starts and ends),
    * level of the message (error, warning, or info), and
    * which source file (and lines) it references.
 5. _Advanced_: In case of wrong source files, run `texlogparser -d` on the log
    and note on which lines it changes file scopes in wrong ways.   

If you _also_ know a little Ruby, please consider translating those data into 
    [a (failing) test](https://github.com/reitzig/texlogparser/blob/master/test/test_texlogparser.rb)
and open a pull request.

Some preemptive notes:
 * Issues around messages below warning level have low priority.
 * Problems caused by inopportune linebreaks are _probably_ out of scope.
 
**Bonus:** Convince as many package maintainers to use the same standardized, robust way of writing to the log.
 
### Rubyists

Any feedback about the code quality and usefulness of the documentation would be 
very appreciated. Particular areas of interest include:

 * Is the API designed in useful ways?
 * Does the documentation cover all your questions?
 * Is the Gem structured properly?
 * What can be improved to encourage code contributions?
 * Does the CLI script have problems on any platform?
 
### Contributors

 * [egreg](https://tex.stackexchange.com/users/4427/egreg) and
   [David Carlisle](https://tex.stackexchange.com/users/1090/david-carlisle)
   provided helpful test cases and insight in LaTeX Stack Exchange chat. 