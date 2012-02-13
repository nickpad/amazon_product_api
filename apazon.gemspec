# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "apazon/version"

Gem::Specification.new do |s|
  s.name        = "apazon"
  s.version     = Apazon::VERSION
  s.authors     = ["Nick Dainty"]
  s.email       = ["nick@npad.co.uk"]
  s.homepage    = "https://github.com/nickpad/apazon"
  s.summary     = %q{Amazon Product Advertising API Client}
  s.description = %q{An extremely minimal client for Amazon Product Advertising REST API}

  s.rubyforge_project = "apazon"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
