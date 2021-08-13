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
  spec.files = `git ls-files -z`.split("\x0").select do |f|
    f.start_with?('lib/') ||
      [
        'bin/libyear-bundler',
        'libyear-bundler.gemspec',
        'LICENSE.txt'
      ].include?(f)
  end
  spec.bindir = "bin"
  spec.executables = ["libyear-bundler"]
  spec.require_paths = ["lib"]

  # We deliberately support dead rubies, as long as possible. It's important
  # that people with badly out-of-date systems can still measure how bad they
  # are.
  spec.required_ruby_version = ">= 2.1"

  # We will support bundler 1 as long as we can. See `required_ruby_version`
  # above.
  spec.add_dependency "bundler", ">= 1.14", "< 3"

  spec.add_development_dependency "rspec", "~> 3.9"

  # rubocop 0.57 drops support for ruby 2.1, so 0.56 is the highest we can
  # use. We're going to support ruby 2.1 as long as possible. See above.
  spec.add_development_dependency "rubocop", "~> 0.56.0"
end
