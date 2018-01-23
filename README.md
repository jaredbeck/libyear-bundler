# Libyear

A simple measure of dependency freshness for ruby apps.

```bash
$ libyear-bundler Gemfile
activesupport    4.2.7.1     2016-08-10    5.1.3     2017-08-03       1.0
         i18n      0.8.0     2017-01-31    0.8.6     2017-07-10       0.4
         json      1.8.6     2017-01-13    2.1.0     2017-04-18       0.3
System is 1.7 libyears behind
```

`libyear-bundler` tells you how out-of-date your Gemfile is, in *a single
number*.

# Install

```bash
gem install libyear-bundler
```

## Usage

Run `libyear-bundler` in a directory with a Gemfile.

### `--libyears` (default)

Measures the time between your dependencies' installed and newest versions, in
years.

```bash
$ libyear-bundler Gemfile
     activesupport   4.2.7.1     2016-08-10     5.1.3     2017-08-03     1.0
              i18n     0.8.0     2017-01-31     0.8.6     2017-07-10     0.4
              json     1.8.6     2017-01-13     2.1.0     2017-04-18     0.3
          minitest    5.10.1     2016-12-02    5.10.3     2017-07-21     0.6
 minitest_to_rspec     0.6.0     2015-06-09     0.8.0     2017-01-02     1.6
       ruby_parser     3.8.4     2017-01-13    3.10.1     2017-07-21     0.5
    sexp_processor     4.8.0     2017-02-01    4.10.0     2017-07-17     0.5
       thread_safe     0.3.5     2015-03-11     0.3.6     2017-02-22     2.0
            tzinfo     1.2.2     2014-08-08     1.2.3     2017-03-25     2.6
System is 9.4 libyears behind

```

### `--releases`

Measures the number of releases between your dependencies' installed and newest
versions

```bash
$ libyear-bundler Gemfile --releases
                 activesupport        4.2.7.1     2016-08-10          5.1.3     2017-08-03        37
                          i18n          0.8.0     2017-01-31          0.8.6     2017-07-10         5
                          json          1.8.6     2017-01-13          2.1.0     2017-04-18        12
                      minitest         5.10.1     2016-12-02         5.10.3     2017-07-21         2
             minitest_to_rspec          0.6.0     2015-06-09          0.8.0     2017-01-02         5
                   ruby_parser          3.8.4     2017-01-13         3.10.1     2017-07-21         3
                sexp_processor          4.8.0     2017-02-01         4.10.0     2017-07-17         3
                   thread_safe          0.3.5     2015-03-11          0.3.6     2017-02-22         2
                        tzinfo          1.2.2     2014-08-08          1.2.3     2017-03-25         1
Total releases behind: 70

```

### `--versions`

Measures the number of major, minor, and patch versions between your
dependencies' installed and newest versions

```bash
$ libyear-bundler Gemfile --versions
                 activesupport        4.2.7.1     2016-08-10          5.1.3     2017-08-03      [1, 0, 0]
                          i18n          0.8.0     2017-01-31          0.8.6     2017-07-10      [0, 0, 6]
                          json          1.8.6     2017-01-13          2.1.0     2017-04-18      [1, 0, 0]
                      minitest         5.10.1     2016-12-02         5.10.3     2017-07-21      [0, 0, 2]
             minitest_to_rspec          0.6.0     2015-06-09          0.8.0     2017-01-02      [0, 2, 0]
                   ruby_parser          3.8.4     2017-01-13         3.10.1     2017-07-21      [0, 2, 0]
                sexp_processor          4.8.0     2017-02-01         4.10.0     2017-07-17      [0, 2, 0]
                   thread_safe          0.3.5     2015-03-11          0.3.6     2017-02-22      [0, 0, 1]
                        tzinfo          1.2.2     2014-08-08          1.2.3     2017-03-25      [0, 0, 1]
Major, minor, patch versions behind: 2, 6, 10

```

### `--all`

Returns relevant data for each outdated gem, including 'libyears', 'releases',
and 'versions' metrics

```bash
$ libyear-bundler Gemfile --all
                 activesupport        4.2.7.1     2016-08-10          5.1.3     2017-08-03       1.0        37      [1, 0, 0]
                          i18n          0.8.0     2017-01-31          0.8.6     2017-07-10       0.4         5      [0, 0, 6]
                          json          1.8.6     2017-01-13          2.1.0     2017-04-18       0.3        12      [1, 0, 0]
                      minitest         5.10.1     2016-12-02         5.10.3     2017-07-21       0.6         2      [0, 0, 2]
             minitest_to_rspec          0.6.0     2015-06-09          0.8.0     2017-01-02       1.6         5      [0, 2, 0]
                   ruby_parser          3.8.4     2017-01-13         3.10.1     2017-07-21       0.5         3      [0, 2, 0]
                sexp_processor          4.8.0     2017-02-01         4.10.0     2017-07-17       0.5         3      [0, 2, 0]
                   thread_safe          0.3.5     2015-03-11          0.3.6     2017-02-22       2.0         2      [0, 0, 1]
                        tzinfo          1.2.2     2014-08-08          1.2.3     2017-03-25       2.6         1      [0, 0, 1]
System is 9.4 libyears behind
Total releases behind: 70
Major, minor, patch versions behind: 2, 6, 10
```

### `--grand-total`

With no other options, returns the grand-total of libyears. Used with other
flags, returns the associated grand-total.

```bash
$ libyear-bundler Gemfile --grand-total
9.4

$ libyear-bundler Gemfile --releases --grand-total
70

$ libyear-bundler Gemfile --versions --grand-total
[2, 6, 10]

$ libyear-bundler Gemfile --all --grand-total
9.4
70
[2, 6, 10]
```

## Contributing

See CONTRIBUTING.md

## Acknowledgements

The inspiration for libyear comes from the technical report “Measuring
Dependency Freshness in Software Systems”[1].

---
[1] J. Cox, E. Bouwers, M. van Eekelen and J. Visser, Measuring Dependency
Freshness in Software Systems. In Proceedings of the 37th International
Conference on Software Engineering (ICSE 2015), May 2015
https://ericbouwers.github.io/papers/icse15.pdf
