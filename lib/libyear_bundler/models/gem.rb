require 'net/http'
require 'uri'
require 'json'

module LibyearBundler
  module Models
    # Logic and information pertaining to the installed and newest versions of
    # a gem
    class Gem
      def initialize(name, installed_version, newest_version, release_date_cache)
        unless release_date_cache.nil? || release_date_cache.is_a?(ReleaseDateCache)
          raise TypeError, 'Invalid release_date_cache'
        end
        @name = name
        @installed_version = installed_version
        @newest_version = newest_version
        @release_date_cache = release_date_cache
      end

      class << self
        def release_date(gem_name, gem_version)
          dep = nil
          begin
            dep = ::Bundler::Dependency.new(gem_name, gem_version)
          rescue ::Gem::Requirement::BadRequirementError => e
            report_problem(gem_name, <<-MSG)
Could not find release date for: #{gem_name}
#{e}
Maybe you used git in your Gemfile, which libyear doesn't support yet. Contributions welcome.
            MSG
            return nil
          end
          tuples, _errors = ::Gem::SpecFetcher.fetcher.search_for_dependency(dep)
          if tuples.empty?
            report_problem(gem_name, "Could not find release date for: #{gem_name}")
            return nil
          end
          tup, source = tuples.first # Gem::NameTuple
          spec = source.fetch_spec(tup) # raises Gem::RemoteFetcher::FetchError
          spec.date.to_date
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
          self.class.release_date(name, installed_version)
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
          self.class.release_date(name, newest_version)
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
          uri = URI.parse("https://rubygems.org/api/v1/versions/#{name}.json")
          response = Net::HTTP.get_response(uri)
          parsed_response = JSON.parse(response.body)
          parsed_response.map { |version| version['number'] }
        end
      end
    end
  end
end
