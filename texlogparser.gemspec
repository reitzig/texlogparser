Gem::Specification.new do |s|
  s.name        = 'tex_log_parser'
  s.version     = '1.0.0.pre.2'
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

  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'

  s.metadata['yard.run'] = 'yri' # use "yard" to build full HTML docs.
end
