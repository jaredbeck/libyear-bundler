require 'net/http'
require 'uri'
require 'json'

module Calculators
  # The version sequence delta is the number of releases between the newest and
  # installed versions of the gem
  class VersionSequenceDelta
    class << self
      def calculate(gem)
        uri = URI.parse("https://rubygems.org/api/v1/versions/#{gem[:name]}.json")
        response = Net::HTTP.get_response(uri)
        versions = JSON.parse(response.body).map { |version| version["number"] }
        newest_seq = versions.index(gem[:newest][:version])
        installed_seq = versions.index(gem[:installed][:version])
        installed_seq - newest_seq
      end
    end
  end
end
