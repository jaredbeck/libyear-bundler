# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'libyear_bundler/version'

Gem::Specification.new do |spec|
  spec.name = "libyear-bundler"
  spec.version = LibyearBundler::VERSION
  spec.authors = ["Jared Beck"]
  spec.email = ["jared@jaredbeck.com"]
  spec.summary = "A simple measure of dependency freshness"
  spec.homepage = "https://libyear.com"
  spec.licenses = ["GPL-3.0"]
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "bin"
  spec.executables = ["libyear-bundler"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.1"
  spec.add_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rspec"
end
