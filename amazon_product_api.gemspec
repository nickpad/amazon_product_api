# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "amazon_product_api/version"

Gem::Specification.new do |s|
  s.name        = "amazon_product_api"
  s.version     = AmazonProductAPI::VERSION
  s.authors     = ["Nick Dainty"]
  s.email       = ["nick@npad.co.uk"]
  s.homepage    = "https://github.com/nickpad/amazon_product_api"
  s.summary     = %q{Amazon Product Advertising API Client}
  s.description = %q{An extremely minimal client for Amazon Product Advertising REST API}

  s.rubyforge_project = "amazon_product_api"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
