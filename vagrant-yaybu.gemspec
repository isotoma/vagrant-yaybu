# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vagrant-yaybu/version"

Gem::Specification.new do |s|
  s.name        = "vagrant-yaybu"
  s.version     = Vagrant::Yaybu::VERSION
  s.authors     = ["John Carr"]
  s.email       = ["john.carr@isotoma.com"]
  s.homepage    = ""
  s.summary     = %q{Teach Vagrant about Yaybu}
  s.description = %q{This plugin adds a Yaybu 'push' provisioner to Vagrant}

  s.rubyforge_project = "vagrant-yaybu"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
