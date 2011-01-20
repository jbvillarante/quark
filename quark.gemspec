# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{quark}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Anna Marseille D. Gabutero <agabutero@friendster.com>", "Andro Salinas <asalinas@friendster.com>"]
  s.date = %q{2010-12-17}
  s.description = %q{Quark encapsulates Friendster API v1 for Project Neutron.}
  s.email = %q{release@friendster.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "autotest/discover.rb",
    "lib/quark.rb",
    "lib/quark/client.rb",
    "lib/quark/request.rb",
    "lib/quark/session.rb",
    "quark.gemspec",
    "spec/data/albums_response_valid.json",
    "spec/data/login_response_valid.json",
    "spec/data/photo_response_valid.json",
    "spec/data/photos_response_valid.json",
    "spec/data/primary_photo_response_valid.json",
    "spec/data/session_response_valid.json",
    "spec/data/token_response_valid.json",
    "spec/data/user_response_valid.json",
    "spec/data/user_response_valid.xml",
    "spec/helper.rb",
    "spec/quark/client_spec.rb",
    "spec/quark/request_spec.rb",
    "spec/quark/session_spec.rb"
  ]
  s.homepage = %q{http://github.com/friendster/quark}
  s.licenses = ["Proprietary"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Friendster v1 API wrapper}
  s.test_files = [
    "spec/helper.rb",
    "spec/quark/client_spec.rb",
    "spec/quark/request_spec.rb",
    "spec/quark/session_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<typhoeus>, [">= 0.2.0"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.6"])
      s.add_development_dependency(%q<rspec>, [">= 2"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, [">= 1.4.3"])
      s.add_runtime_dependency(%q<typhoeus>, [">= 0.2.0"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.6"])
      s.add_development_dependency(%q<rspec>, ["> 2.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_development_dependency(%q<nokogiri>, [">= 1.4.3"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<typhoeus>, [">= 0.2.0"])
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<rspec>, [">= 2"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.3"])
      s.add_dependency(%q<typhoeus>, [">= 0.2.0"])
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<rspec>, ["> 2.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.3"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<typhoeus>, [">= 0.2.0"])
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<rspec>, [">= 2"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.3"])
    s.add_dependency(%q<typhoeus>, [">= 0.2.0"])
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<rspec>, ["> 2.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.1"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.3"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

