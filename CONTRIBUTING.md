# Contributing Guide

## Development

Pull requests are welcome.

## Support for old rubies

We test all minor versions of ruby, back to 2.1. It's important that people with
badly out-of-date systems can still measure how bad they are.

### Installing old rubies

> When building Ruby 2.3 or older, [use] OpenSSL 1.0 ..
> https://github.com/rbenv/ruby-build/wiki#openssl-version-compatibility

```bash
brew install rbenv/tap/openssl@1.0
RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.0)" \
  rbenv install 2.1.10
```

## Lint

Linting is only done with the oldest supported ruby version. Now that we have
separate `/gemfiles` it's technically possible to specify different rubocops,
and thus lint any ruby version, but then we'd have to have different rubocop
config files for the different rubocop versions.

```bash
rbenv shell 2.1.10 # only lint with oldest supported ruby
rm .ruby-version # don't want rubocop looking at this, in case it was different
export BUNDLE_GEMFILE=gemfiles/ruby-2.1.rb
bundle install
bundle exec rubocop
unset BUNDLE_GEMFILE
```

## Test

```bash
rbenv shell 2.4.10
export BUNDLE_GEMFILE=gemfiles/ruby-2.4.rb
bundle install
bundle exec rspec
unset BUNDLE_GEMFILE
```

## Releases

1. Set the version in `lib/libyear_bundler/version.rb`
   - Follow SemVer
   - Only use integer-dot-integer-dot-integer format, never "pre-releases"
1. In the changelog,
   - Replace "Unreleased" with the date in ISO-8601 format
   - Add a new "Unreleased" section
1. Commit
1. git push origin master
1. Wait for CI to pass before tagging
1. git tag -a -m "v0.5.0" "v0.5.0" # or whatever number
1. git push --tags origin master
1. gem build libyear-bundler.gemspec
1. gem push libyear-bundler-0.5.0.gem
