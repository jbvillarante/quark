require 'rubygems'
require 'bundler'

begin
  Bundler.require(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec/core'
require 'rspec/core/rake_task'
require 'rake/rdoctask'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "quark"
  gem.homepage = "http://github.com/friendster/quark"
  gem.license = "Proprietary"
  gem.summary = %Q{Friendster v1 API wrapper}
  gem.description = %Q{Quark encapsulates Friendster API v1 for Project Neutron.}
  gem.email = "release@friendster.com"
  gem.authors = ["Anna Marseille D. Gabutero <agabutero@friendster.com>", "Andro Salinas <asalinas@friendster.com>", "Zander Magtipon <amagtipon@friendster.com>", "Arzumy MD <arzumy@mol.com>", "Arnold Putong <aputong@friendster.com>", "Paolo Alexis Falcone <pfalcone@friendster.com>"]
end

Jeweler::RubygemsDotOrgTasks.new

task :default => :spec
RSpec::Core::RakeTask.new

Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "quark #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
