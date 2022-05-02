require 'simplecov'
SimpleCov.start

require 'libyear_bundler'
require 'rspec'

require 'webmock/rspec'
WebMock.disable_net_connect!

require 'vcr'
VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end
