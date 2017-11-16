require 'bundler/lockfile_parser'
require 'bundler/ruby_version'
require 'date'
require 'net/http'
require 'open3'
require 'yaml'

require 'libyear_bundler/calculators/libyear'
require 'libyear_bundler/calculators/version_number_delta'
require 'libyear_bundler/calculators/version_sequence_delta'

module LibyearBundler
  module Models
    class Ruby
      def initialize(lockfile)
        @lockfile = lockfile
      end

      def installed_version
        @_installed_version ||= begin
          version_from_bundler || version_from_rbenv || version_from_ruby
        end
      end

      def installed_version_release_date
        release_date(installed_version.to_s)
      end

      def libyears
        ::LibyearBundler::Calculators::Libyear.calculate(
          release_date(installed_version.to_s),
          release_date(newest_version.to_s)
        )
      end

      def name
        'ruby'
      end

      # We'll only consider non-prerelease versions when determining the
      # newest version
      def newest_version
        newest = all_versions.detect do |version|
          !::Gem::Version.new(version['version']).prerelease?
        end
        ::Gem::Version.new(newest['version'])
      end

      def newest_version_release_date
        release_date(newest_version.to_s)
      end

      def outdated?
        installed_version != newest_version
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

      # The following URL is the only official, easily-parseable document with
      # Ruby version information that I'm aware of, but is not supported as such
      # (https://github.com/ruby/www.ruby-lang.org/pull/1637#issuecomment-344934173).
      # It's been recommend that ruby-lang.org provide a supported document:
      # https://github.com/ruby/www.ruby-lang.org/pull/1637#issuecomment-344934173
      # TODO: Use supported document with version information if it becomes
      # available.
      def all_versions
        @_all_versions ||= begin
          uri = ::URI.parse("https://raw.githubusercontent.com/ruby/www.ruby-lang.org/master/_data/releases.yml")
          response = ::Net::HTTP.get_response(uri)
          # The Date object is passed through here due to a bug where in
          # YAML#safe_load
          # https://github.com/ruby/psych/issues/262
          ::YAML.safe_load(response.body, [Date])
        end
      end

      def installed_version_sequence_index
        versions_sequence.index(installed_version.to_s)
      end

      def newest_version_sequence_index
        versions_sequence.index(newest_version.to_s)
      end

      def release_date(version)
        v = all_versions.detect { |ver| ver['version'] == version }
        # YAML#safe_load provides an already-parsed Date object, so the following
        # is a Date object
        v['date']
      end

      def shell_out_to_rbenv
        'rbenv version-name'
      end

      def shell_out_to_ruby
        `ruby --version`.split[1]
      end

      def version_from_bundler
        ruby_version_string = ::Bundler::LockfileParser.new(@lockfile).ruby_version
        return if ruby_version_string.nil?

        ::Bundler::RubyVersion.from_string(ruby_version_string).gem_version.release
      end

      def version_from_rbenv
        stdout, _stderr, status = ::Open3.capture3(shell_out_to_rbenv)
        ::Gem::Version.new(stdout).release if status.success?
      end

      def version_from_ruby
        ::Gem::Version.new(shell_out_to_ruby).release
      end

      def versions_sequence
        all_versions.map { |version| version['version'] }
      end
    end
  end
end
