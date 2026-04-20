require 'English'
require 'net/http'
require 'uri'
require 'json'

module LibyearBundler
  module Models
    # Logic and information pertaining to the installed and newest versions of
    # a gem
    class Gem
      def initialize(name, installed_version, newest_version, release_date_cache, http, source: 'https://rubygems.org/')
        unless release_date_cache.nil? || release_date_cache.is_a?(ReleaseDateCache)
          raise TypeError, 'Invalid release_date_cache'
        end
        @name = name
        @installed_version = installed_version
        @newest_version = newest_version
        @release_date_cache = release_date_cache
        @http = http
        @source = source
      end

      class << self
        def release_date(gem_name, gem_version, http, source = 'https://rubygems.org/')
          if source.include?('rubygems.pkg.github.com')
            release_date_github_packages(gem_name, gem_version, source)
          elsif source == 'https://rubygems.org/'
            release_date_rubygems(gem_name, gem_version, http)
          else
            report_problem(gem_name, "Skipped: #{gem_name} (unsupported source: #{source})")
            nil
          end
        end

        def gh_available?
          system('which gh > /dev/null 2>&1')
        end

        private

        def release_date_rubygems(gem_name, gem_version, http)
          uri = URI.parse(
            "https://rubygems.org/api/v2/rubygems/#{gem_name}/versions/#{gem_version}.json"
          )
          request = Net::HTTP::Get.new(uri)
          response = http.request(request)
          if response.is_a?(Net::HTTPSuccess)
            parsed_response = JSON.parse(response.body)
            Date.parse(parsed_response["version_created_at"])
          else
            report_problem(
              gem_name,
              "Release date not found: #{gem_name}: rubygems.org responded with #{response.code}"
            )
            nil
          end
        rescue StandardError => e
          report_problem(gem_name, "Release date not found: #{gem_name}: #{e.inspect}")
        end

        def release_date_github_packages(gem_name, gem_version, source)
          unless gh_available?
            report_problem(gem_name, "Skipped: #{gem_name} (private source, gh CLI not available)")
            return nil
          end

          org = source.split('/').last.delete('/')
          output, success = gh_api_call("/orgs/#{org}/packages/rubygems/#{gem_name}/versions")
          return nil unless success

          versions = JSON.parse(output)
          version_data = versions.find { |v| v['name'] == gem_version.to_s }
          return nil unless version_data

          Date.parse(version_data['created_at'])
        rescue StandardError => e
          report_problem(gem_name, "Release date not found: #{gem_name}: #{e.inspect}")
          nil
        end

        def gh_api_call(endpoint)
          output = `gh api #{endpoint} 2>&1`
          [output, $CHILD_STATUS.success?]
        end

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
          self.class.release_date(name, installed_version, @http, @source)
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
          self.class.release_date(name, newest_version, @http, @source)
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
          request = Net::HTTP::Get.new(uri)
          response = @http.request(request)
          parsed_response = JSON.parse(response.body)
          parsed_response.map { |version| version['number'] }
        end
      end
    end
  end
end
