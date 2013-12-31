require 'rubygems'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'


RSpec::Core::RakeTask.new(:test) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :test
