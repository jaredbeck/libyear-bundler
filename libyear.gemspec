# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libyear/version'

Gem::Specification.new do |spec|
  spec.name          = "libyear"
  spec.version       = Libyear::VERSION
  spec.authors       = ["Jared Beck"]
  spec.email         = ["jared@jaredbeck.com"]
  spec.summary       = "A simple measure of software dependency freshness"
  spec.homepage      = "https://libyear.com"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "bin"
  spec.executables   = ["libyear"]
  spec.require_paths = ["lib"]
  spec.add_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
end
