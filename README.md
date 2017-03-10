# Libyear

A simple measure of dependency freshness for ruby apps.

A libyear (library year) is a measure of how old a software dependency is.

If your system has two dependencies, the first one year old, the second three,
then your system is four libyears out-of-date.

A dependency is one year old when the version you are using is one year older
than its latest version.

## Usage

Early access. Output and usage subject to change.

```
gem install libyear-bundler
libyear-bundler Gemfile
       activesupport   4.2.7.1     2016-08-10     5.0.1     2016-12-21       0.4
                json     1.8.6     2017-01-13     2.0.3     2017-01-12       0.0
   minitest_to_rspec     0.6.0     2015-06-09     0.8.0     2017-01-02       1.6
System is 1.9 libyears behind
```

## Development

```
ruby -I lib bin/libyear-bundler spec/fixtures/01/Gemfile
```
