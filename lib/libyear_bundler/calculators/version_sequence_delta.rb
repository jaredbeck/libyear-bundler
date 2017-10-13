require 'net/http'
require 'uri'
require 'json'

module Calculators
  # The version sequence delta is the number of releases between the newest and
  # installed versions of the gem
  class VersionSequenceDelta
    class << self
      def calculate(gem)
        versions =  gem_version_details(gem[:name]).map { |version| version["number"] }
        newest_seq = versions.index(gem[:newest][:version])
        installed_seq = versions.index(gem[:installed][:version])
        installed_seq - newest_seq
      end

      private

      # docs: http://guides.rubygems.org/rubygems-org-api/#gem-version-methods
      def gem_version_details(gem_name)
        uri = URI.parse("https://rubygems.org/api/v1/versions/#{gem_name}.json")
        response = Net::HTTP.get_response(uri)
        JSON.parse(response.body)
      end
    end
  end
end
