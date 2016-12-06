# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "marketo/version"

Gem::Specification.new do |s|
  s.name        = "marketo_rest"
  s.version     = Marketo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Kelly", "Evan Wheeler"]
  s.email       = ["john@backupify.com", "ewheeler@datto.com"]
  s.homepage    = ""
  s.summary     = %q{Gem for interacting with the Marketo REST API}
  s.description = %q{Gem for interacting with the Marketo REST API}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('faraday')
  s.add_development_dependency('vcr')
  s.add_development_dependency('timecop')
  s.add_development_dependency('rspec')
  s.add_development_dependency('webmock')
end
