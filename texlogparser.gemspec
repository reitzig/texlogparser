# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tex_log_parser/version'

Gem::Specification.new do |s|
  s.name        = 'tex_log_parser'
  s.version     = TexLogParser::VERSION
  s.date        = '2018-03-01'
  s.summary     = 'Parses log files of (La)TeX engines'
  s.description = s.summary
  s.authors     = ['Raphael Reitzig']
  s.email       = '4246780+reitzig@users.noreply.github.com'
  s.homepage    = 'http://github.com/reitzig/texlogparser'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.3.0'

  s.executables = ['texlogparser']
  s.files       = Dir['lib/**/*.rb', 'bin/*', 'LICENSE', '*.md']

  s.add_development_dependency 'minitest', '~> 5.10'
  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'yard', '~> 0.9'

  s.add_runtime_dependency 'json', '~> 2.1'

  s.metadata['yard.run'] = 'yri' # use "yard" to build full HTML docs.
end
