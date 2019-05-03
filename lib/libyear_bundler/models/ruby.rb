require 'bundler/lockfile_parser'
require 'bundler/ruby_version'
require 'date'
require 'net/http'
require 'yaml'

require 'libyear_bundler/calculators/libyear'
require 'libyear_bundler/calculators/version_number_delta'
require 'libyear_bundler/calculators/version_sequence_delta'

module LibyearBundler
  module Models
    # Logic and information pertaining to the installed and newest Ruby versions
    class Ruby
      RUBY_VERSION_DATA_URL = "https://raw.githubusercontent.com/ruby/" \
        "www.ruby-lang.org/master/_data/releases.yml".freeze

      def initialize(lockfile)
        @lockfile = lockfile
      end

      def installed_version
        @_installed_version ||= begin
          version_from_bundler ||
            version_from_ruby_version_file ||
            version_from_ruby
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

      def newest_version
        ::Gem::Version.new(all_stable_versions.first)
      end

      def newest_version_release_date
        release_date(newest_version.to_s)
      end

      def outdated?
        installed_version < newest_version
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
          uri = ::URI.parse(RUBY_VERSION_DATA_URL)
          response = ::Net::HTTP.get_response(uri)
          # The Date object is passed through here due to a bug in
          # YAML#safe_load
          # https://github.com/ruby/psych/issues/262
          ::YAML.safe_load(response.body, [Date])
        end
      end

      # We'll only consider non-prerelease versions when analyzing ruby version,
      # which we also implcitly do for gem versions because that's bundler's
      # default behavior
      def all_stable_versions
        stable_releases = all_versions.reject do |version|
          ::Gem::Version.new(version['version']).prerelease?
        end
        stable_releases.map { |release| release['version'] }
      end

      def installed_version_sequence_index
        all_stable_versions.index(installed_version.to_s)
      end

      def newest_version_sequence_index
        all_stable_versions.index(newest_version.to_s)
      end

      def release_date(version)
        v = all_stable_versions.detect { |ver| ver['version'] == version }

        if v.nil?
          raise format('Cannot determine release date for ruby %s', version)
        end

        # YAML#safe_load provides an already-parsed Date object, so the following
        # is a Date object
        v['date']
      end

      def shell_out_to_ruby
        # ruby appends a 'p' followed by the patch level number
        # to the version number for stable releases, which returns
        # a false positive using `::Gem::Version#prerelease?`.
        # Understandably, because ruby is not a gem, but we'd like
        # to use `prerelease?`.
        # Pre-releases are appended with 'dev', and so adhere to
        # `::Gem::Version`'s definition of a pre-release.
        # Sources:
        #   - https://github.com/ruby/ruby/blob/trunk/version.h#L37
        #   - https://ruby-doc.org/stdlib-1.9.3/libdoc/rubygems/rdoc/Version.html
        `ruby --version`.split[1].gsub(/p\d*/, '')
      end

      def version_from_bundler
        return unless File.exist?(@lockfile)
        ruby_version_string = ::Bundler::LockfileParser
          .new(@lockfile)
          .ruby_version
        return if ruby_version_string.nil?

        ::Bundler::RubyVersion.from_string(ruby_version_string).gem_version
      end

      def version_from_ruby_version_file
        return unless ::File.exist?('.ruby-version')
        ::Gem::Version.new(::File.read('.ruby-version').strip)
      end

      def version_from_ruby
        ::Gem::Version.new(shell_out_to_ruby)
      end
    end
  end
end
