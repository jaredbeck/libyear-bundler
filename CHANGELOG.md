# libyear

This project follows [semver 2.0.0][1] and the recommendations
of [keepachangelog.com][2].

## Unreleased

Breaking changes:

- None

Added:

- None

Fixed:

- Stable Ruby releases are no longer considered pre-releases (80534fa)
- Avoid crash due to malformed version strings by skipping those dependencies (7b0b2cf)

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
