$:.unshift File.expand_path('../lib', __FILE__)
require 'ffi-ogr/version'

task :build do
  system 'gem build ffi-ogr.gemspec'
end

task :release => :build do
  system "gem push ffi-ogr-#{OGR::VERSION}.gem"
end

require 'rspec/core/rake_task'
task :default => :spec
RSpec::Core::RakeTask.new
