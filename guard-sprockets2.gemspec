# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "guard/sprockets2/version"

Gem::Specification.new do |s|
  s.name        = "guard-sprockets2"
  s.version     = Guard::Sprockets2Version::VERSION
  s.authors     = ["Steve Hodgkiss"]
  s.email       = ["steve@hodgkiss.me"]
  s.homepage    = "https://github.com/stevehodgkiss/guard-sprockets2"
  s.summary     = %q{Guard for compiling sprockets assets}
  s.description = %q{}

  s.rubyforge_project = "guard-sprockets2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency             'guard'
  s.add_dependency             'sprockets', '~> 2.0'
  
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'coffee-script'
  s.add_development_dependency 'uglifier'
  s.add_development_dependency 'sass'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
  s.add_development_dependency 'rails', '~> 3.1'
end
