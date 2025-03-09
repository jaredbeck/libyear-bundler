# libyear

This project follows [semver 2.0.0][1] and the recommendations
of [keepachangelog.com][2].

## Unreleased

Breaking changes:

- None

Added:

- None

Fixed:

- [#44](https://github.com/jaredbeck/libyear-bundler/pull/44) -
  Fixed warnings about "ostruct" when running in Ruby 3.4

## 0.9.0 (2025-03-05)

Breaking changes:

- None

Added:

- [#42](https://github.com/jaredbeck/libyear-bundler/pull/42) -
  Added support for `--json` CLI option

Fixed:

- [#43](https://github.com/jaredbeck/libyear-bundler/pull/43) -
  Fixed libyears calculation for Ruby version

## 0.8.0 (2024-09-13)

Breaking changes:

- None

Added:

- [#39](https://github.com/jaredbeck/libyear-bundler/pull/39) -
  Added support for `--sort` cli option

Fixed:

- [#40](https://github.com/jaredbeck/libyear-bundler/pull/40) - Report
  problematic release dates only once per gem name

## 0.7.0 (2024-05-11)

Breaking changes:

- None

Added:

- [#37](https://github.com/jaredbeck/libyear-bundler/pull/37) -
  Added support for engine-x.y.z .ruby-version format

Fixed:

- [#32](https://github.com/jaredbeck/libyear-bundler/pull/32) -
  Fix reading of Ruby version from Gemfile.lock
- [#25](https://github.com/jaredbeck/libyear-bundler/issues/25) -
  Support private gems with dummy packages on public repository

## 0.6.1 (2022-05-02)

Breaking changes:

- None

Added:

- None

Fixed:

- [#23](https://github.com/jaredbeck/libyear-bundler/pull/23) -
  ArgumentError in Psych 4
- Add explicit timeout to the HTTP request that gets ruby release dates

## 0.6.0 (2021-08-12)

Breaking changes:

- None

Added:

- [#20](https://github.com/jaredbeck/libyear-bundler/pull/20) -
  Add --cache option to cache release dates

Fixed:

- None

## 0.5.3 (2020-06-26)

Breaking changes:

- None

Added:

- None

Fixed:

- Fix TypeError in `libyear-bundler --all` (#17)
- Fix ruby version issue for other metrics (#15)

## 0.5.2 (2019-05-09)

Breaking changes:

- None

Added:

- None

Fixed:

- Handle failure to determine release date of ruby

## 0.5.1 (2019-05-09)

Breaking changes:

- None

Added:

- None

Fixed:

- Stable Ruby releases are no longer considered pre-releases (80534fa)
- Avoid crash due to malformed version strings by skipping those dependencies (7b0b2cf)

Dependencies:

- Support bundler 2

## 0.5.0 (2017-12-27)

Breaking changes:

- None

Added:

- [#10](https://github.com/jaredbeck/libyear-bundler/pull/10)
  Include Ruby version in metrics calculations

Fixed:

- None

## 0.4.0 (2017-07-07)

Breaking changes:

- None

Added:

- [#3](https://github.com/jaredbeck/libyear-bundler/pull/3)
  Add --versions and --releases

Fixed:

- None

## 0.3.0 (2017-03-24)

Breaking changes:

- None

Added:

- [#1](https://github.com/jaredbeck/libyear-bundler/pull/1)
  Add --grand-total option

Fixed:

- None

## 0.2.0 (2017-03-10)

Breaking changes:

- Rename project
  - Rename project from libyear-rb to libyear-bundler
  - Rename binary from libyear to libyear-bundler
  - Discussion: https://github.com/jaredbeck/libyear-rb/issues/1

Added:

- None

Fixed:

- None

## 0.1.3 (2017-03-07)

Breaking changes:

- None

Added:

- None

Fixed:

- Don't crash when Gemfile uses git

## 0.1.2 (2017-02-16)

Breaking changes:

- None

Added:

- None

Fixed:

- Better handling of weird sources like rails-assets
- Wider report columns

## 0.1.1 (2017-02-14)

Breaking changes:

- None

Added:

- None

Fixed:

- Better handling of error when bundle outdated fails

## 0.1.0 (2017-02-13)

Initial version. Proof of concept.

[1]: http://semver.org/spec/v2.0.0.html
[2]: http://keepachangelog.com/
