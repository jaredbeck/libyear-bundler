require 'net/http'
require 'uri'
require 'json'

module LibyearBundler
  module Models
    # Logic and information pertaining to the installed and newest versions of
    # a gem
    class Gem
      def initialize(name, installed_version, newest_version, release_date_cache, http)
        unless release_date_cache.nil? || release_date_cache.is_a?(ReleaseDateCache)
          raise TypeError, 'Invalid release_date_cache'
        end
        @name = name
        @installed_version = installed_version
        @newest_version = newest_version
        @release_date_cache = release_date_cache
        @http = http
      end

      class << self
        def release_date(gem_name, gem_version, http)
          # uri = URI.parse("https://rubygems.org/api/v2/rubygems/#{gem_name}/versions/#{gem_version}.json")
          uri = "/api/v2/rubygems/#{gem_name}/versions/#{gem_version}.json"
          request = Net::HTTP::Get.new(uri)
          response = http.request(request)
          if response.is_a?(Net::HTTPSuccess)
            parsed_response = JSON.parse(response.body)
            Date.parse(parsed_response["version_created_at"])
          else
            report_problem(
              gem_name,
              "Release date not found: #{gem_name}: #{http.address} responded with #{response.code}"
            )
            nil
          end
        rescue StandardError => e
          report_problem(gem_name, "Release date not found: #{gem_name}: #{e.inspect}")
        end

        private

        def report_problem(gem_name, message)
          @reported_gems ||= {}
          @reported_gems[gem_name] ||= begin
            $stderr.puts(message)
            true
          end
        end
      end

      def installed_version
        ::Gem::Version.new(@installed_version)
      end

      def installed_version_release_date
        if @release_date_cache.nil?
          self.class.release_date(name, installed_version, @http)
        else
          @release_date_cache[name, installed_version]
        end
      end

      def installed_version_sequence_index
        versions_sequence.index(installed_version.to_s)
      end

      def libyears
        ::LibyearBundler::Calculators::Libyear.calculate(
          installed_version_release_date,
          newest_version_release_date
        )
      end

      def name
        @name
      end

      def newest_version
        ::Gem::Version.new(@newest_version)
      end

      def newest_version_sequence_index
        versions_sequence.index(newest_version.to_s)
      end

      def newest_version_release_date
        if @release_date_cache.nil?
          self.class.release_date(name, newest_version, @http)
        else
          @release_date_cache[name, newest_version]
        end
      end

      def version_number_delta
        ::LibyearBundler::Calculators::VersionNumberDelta.calculate(
          installed_version,
          newest_version
        )
      end

      def version_sequence_delta
        ::LibyearBundler::Calculators::VersionSequenceDelta.calculate(
          installed_version_sequence_index,
          newest_version_sequence_index
        )
      end

      private

      # docs: http://guides.rubygems.org/rubygems-org-api/#gem-version-methods
      # Versions are returned ordered by version number, descending
      def versions_sequence
        @_versions_sequence ||= begin
          # uri = URI.parse("https://rubygems.org/api/v1/versions/#{name}.json")
          uri = "/api/v1/versions/#{name}.json"
          request = Net::HTTP::Get.new(uri)
          response = @http.request(request)
          parsed_response = JSON.parse(response.body)
          parsed_response.map { |version| version['number'] }
        end
      end
    end
  end
end
