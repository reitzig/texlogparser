Gem::Specification.new do |s|
  s.name        = 'texlogparser'
  s.version     = '1.0.0.pre.1'
  s.date        = '2018-03-01'
  s.summary     = 'Parses logs from TeX and friends.'
  s.description = s.summary
  s.authors     = ['Raphael Reitzig']
  s.email       = '4246780+reitzig@users.noreply.github.com'
  s.executables = ['texlogparser']
  s.files       = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.homepage    = 'http://github.com/reitzig/texlogparser'
  s.license     = 'MIT'

  s.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.
end
