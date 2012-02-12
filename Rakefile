require "bundler/gem_tasks"

require 'rake/testtask'
require 'rdoc/task'

test_files_pattern = 'test/*_test.rb'
Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.pattern = test_files_pattern
  t.verbose = false
end

RDoc::Task.new

task :default => :test
