require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "quark"
  gem.homepage = "http://github.com/friendster/quark"
  gem.license = "Proprietary"
  gem.summary = %Q{Friendster v1 API wrapper}
  gem.description = %Q{Quark encapsulates Friendster API v1 for Project Neutron.}
  gem.email = "release@friendster.com"
  gem.authors = ["Anna Marseille D. Gabutero <agabutero@friendster.com>", "Andro Salinas <asalinas@friendster.com>"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_runtime_dependency 'typhoeus', '>= 0.2.0'
  gem.add_runtime_dependency "json", ">= 1.4.6"
  gem.add_development_dependency 'rspec', '> 2.0'
  gem.add_development_dependency 'bundler', '~> 1.0.0'
  gem.add_development_dependency 'jeweler', '~> 1.5.1'
  gem.add_development_dependency 'nokogiri', '>= 1.4.3'
  gem.add_development_dependency 'rcov', '>= 0'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'spec'
  test.pattern = 'spec/**/*_spec.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "quark #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
