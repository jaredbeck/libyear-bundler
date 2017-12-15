# Contributing Guide

## Development

Pull requests are welcome.

```bash
bundle install
bundle exec rspec
```

## Releases

1. Set the version in `lib/libyear_bundler/version.rb`
  - Follow SEMVER
  - Only use integer-dot-integer-dot-integer format, never "pre-releases"
1. In the changelog,
  - Replace "Unreleased" with the date in ISO-8601 format
  - Add a new "Unreleased" section
1. Commit
1. git tag -a -m "v0.5.0" "v0.5.0" # or whatever number
1. git push --tags origin master
1. gem build libyear-bundler.gemspec
1. gem push libyear-bundler-0.5.0.gem
