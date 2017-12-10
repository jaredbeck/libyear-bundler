require 'net/http'
require 'uri'
require 'json'

module LibyearBundler
  module Models
    # Logic and information pertaining to the installed and newest versions of
    # a gem
    class Gem
      def initialize(name, installed_version, newest_version)
        @name = name
        @installed_version = installed_version
        @newest_version = newest_version
      end

      def installed_version
        ::Gem::Version.new(@installed_version)
      end

      def installed_version_release_date
        release_date(name, installed_version)
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
        release_date(name, newest_version)
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
          uri = URI.parse("https://rubygems.org/api/v1/versions/#{name}.json")
          response = Net::HTTP.get_response(uri)
          parsed_response = JSON.parse(response.body)
          parsed_response.map { |version| version['number'] }
        end
      end

      # Known issue: Probably performs a network request every time, unless
      # there's some kind of caching.
      def release_date(gem_name, gem_version)
        dep = nil
        begin
          dep = ::Bundler::Dependency.new(gem_name, gem_version)
        rescue ::Gem::Requirement::BadRequirementError => e
          $stderr.puts "Could not find release date for: #{gem_name}"
          $stderr.puts(e)
          $stderr.puts(
            "Maybe you used git in your Gemfile, which libyear doesn't support " \
              "yet. Contributions welcome."
          )
          return nil
        end
        tuples, _errors = ::Gem::SpecFetcher.fetcher.search_for_dependency(dep)
        if tuples.empty?
          $stderr.puts "Could not find release date for: #{gem_name}"
          return nil
        end
        tup, source = tuples.first # Gem::NameTuple
        spec = source.fetch_spec(tup) # raises Gem::RemoteFetcher::FetchError
        spec.date.to_date
      end
    end
  end
end
