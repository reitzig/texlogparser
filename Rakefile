# frozen_string_literal: true

require 'rake/testtask'
require 'yard'

desc 'Run tests'
Rake::TestTask.new do |t|
  t.libs << 'tex_log_parser'
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end

desc 'Build documentation'
YARD::Rake::YardocTask.new do |t|
  # t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
end

task default: :test
