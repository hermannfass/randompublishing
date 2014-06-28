# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'randompublishing/version'

Gem::Specification.new do |spec|
  spec.name          = "randompublishing"
  spec.version       = Randompublishing::VERSION
  spec.authors       = ["Hermann Faß"]
  spec.email         = ["hf@vonabiszet.de"]
  spec.summary       = %q{Publishing of random text, HTML markup, and colors}
  spec.description   = %q{Allows to generate random text in a phantasy language, random HTML markup, and random colors.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
