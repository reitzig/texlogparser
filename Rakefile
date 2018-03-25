require 'rake/testtask'

desc "Run tests"
Rake::TestTask.new do |t|
  t.libs << "texlogparser"
  t.test_files = FileList['test/*.rb']
  t.verbose = true
end

# TODO Task for Doc generation? (yard)
# TODO Tasks for Gem bundling, pushing?

task :default => :test