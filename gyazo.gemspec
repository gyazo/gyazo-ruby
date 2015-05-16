# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gyazo/version'

Gem::Specification.new do |spec|
  spec.name          = "gyazo"
  spec.version       = Gyazo::VERSION
  spec.authors       = ["Toshiyuki Masui", "Sho Hashimoto"]
  spec.email         = ["masui@pitecan.com"]
  spec.description   = %q{Gyazo.com API Wrapper}
  spec.summary       = spec.description
  spec.homepage      = "http://github.com/masui/gyazo-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).reject{|i| i=="Gemfile.lock" }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"

  spec.add_dependency "json"
  spec.add_dependency "httparty"
  spec.add_dependency "httmultiparty"
end
