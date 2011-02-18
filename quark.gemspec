# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{quark}
  s.version = "0.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Anna Marseille D. Gabutero <agabutero@friendster.com>", "Andro Salinas <asalinas@friendster.com>", "Zander Magtipon <amagtipon@friendster.com>"]
  s.date = %q{2011-02-18}
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
    "init.rb",
    "lib/quark.rb",
    "lib/quark/client.rb",
    "lib/quark/invalid_signature_error.rb",
    "lib/quark/request.rb",
    "lib/quark/session.rb",
    "lib/quark/util.rb",
    "quark.gemspec",
    "spec/data/albums_response_valid.json",
    "spec/data/login_response_valid.json",
    "spec/data/photo_response_valid.json",
    "spec/data/photos_response_empty.json",
    "spec/data/photos_response_no_album_id.json",
    "spec/data/photos_response_valid.json",
    "spec/data/post_shoutout_valid.json",
    "spec/data/post_shoutout_valid.xml",
    "spec/data/primary_photo_response_valid.json",
    "spec/data/put_photo_valid.json",
    "spec/data/put_photo_valid.xml",
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
      s.add_runtime_dependency(%q<curb>, ["= 0.7.10"])
      s.add_runtime_dependency(%q<json>, [">= 1.4.6"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.4"])
      s.add_development_dependency(%q<rspec>, [">= 2.4.0"])
      s.add_development_dependency(%q<jeweler>, [">= 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<webmock>, ["= 1.6.2"])
    else
      s.add_dependency(%q<curb>, ["= 0.7.10"])
      s.add_dependency(%q<json>, [">= 1.4.6"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.4"])
      s.add_dependency(%q<rspec>, [">= 2.4.0"])
      s.add_dependency(%q<jeweler>, [">= 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<webmock>, ["= 1.6.2"])
    end
  else
    s.add_dependency(%q<curb>, ["= 0.7.10"])
    s.add_dependency(%q<json>, [">= 1.4.6"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.4"])
    s.add_dependency(%q<rspec>, [">= 2.4.0"])
    s.add_dependency(%q<jeweler>, [">= 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<webmock>, ["= 1.6.2"])
  end
end

