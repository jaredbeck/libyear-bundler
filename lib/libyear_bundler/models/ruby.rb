require 'bundler/lockfile_parser'
require 'bundler/ruby_version'
require 'date'
require 'net/http'
require 'yaml'

require 'libyear_bundler/calculators/libyear'
require 'libyear_bundler/calculators/version_number_delta'
require 'libyear_bundler/calculators/version_sequence_delta'
require 'libyear_bundler/yaml_loader'

module LibyearBundler
  module Models
    # Logic and information pertaining to the installed and newest Ruby versions
    class Ruby
      RUBY_VERSION_DATA_URL = "https://raw.githubusercontent.com/ruby/" \
        "www.ruby-lang.org/master/_data/releases.yml".freeze

      def initialize(lockfile, release_date_cache)
        unless release_date_cache.nil? || release_date_cache.is_a?(ReleaseDateCache)
          raise TypeError, 'Invalid release_date_cache'
        end
        @lockfile = lockfile
        @release_date_cache = release_date_cache
      end

      class << self
        # We'll only consider non-prerelease versions when analyzing ruby version,
        # which we also implcitly do for gem versions because that's bundler's
        # default behavior
        #
        # @return [Array<String>]
        def all_stable_versions
          all_versions.reject do |version|
            ::Gem::Version.new(version).prerelease?
          end
        end

        def newest_version
          ::Gem::Version.new(all_stable_versions.first)
        end

        def newest_version_release_date
          if @release_date_cache.nil?
            release_date(newest_version)
          else
            @release_date_cache[name, newest_version]
          end
        end

        def newest_version_sequence_index
          all_stable_versions.find_index(newest_version.to_s)
        end

        def release_date(version_obj)
          version = version_obj.to_s
          v = all_stable_versions.detect { |ver| ver == version }

          if v.nil?
            raise format('Cannot determine release date for ruby %s', version)
          end

          # YAML#safe_load provides an already-parsed Date object, so the following
          # is a Date object
          v['date']
        end

        private

        # The following URL is the only official, easily-parseable document with
        # Ruby version information that I'm aware of, but is not supported as such
        # (https://github.com/ruby/www.ruby-lang.org/pull/1637#issuecomment-344934173).
        # It's been recommend that ruby-lang.org provide a supported document:
        # https://github.com/ruby/www.ruby-lang.org/pull/1637#issuecomment-344934173
        # TODO: Use supported document with version information if it becomes
        # available.
        #
        # @return [Array<String>]
        def all_versions
          @_all_versions ||= begin
            uri = ::URI.parse(RUBY_VERSION_DATA_URL)
            opt = { open_timeout: 3, read_timeout: 5, use_ssl: true }
            response = ::Net::HTTP.start(uri.hostname, uri.port, opt) do |con|
              con.request_get(uri.path)
            end
            if response.is_a?(::Net::HTTPSuccess)
              YAMLLoader.safe_load(response.body).map { |release| release['version'] }
            else
              warn format('Unable to get Ruby version list: response code: %s', response.code)
              []
            end
          rescue ::Timeout::Error
            warn 'Unable to get Ruby version list: network timeout'
            []
          end
        end
      end

      def installed_version
        @_installed_version ||= begin
          version_from_bundler ||
            version_from_ruby_version_file ||
            version_from_ruby
        end
      end

      def installed_version_release_date
        if @release_date_cache.nil?
          self.class.release_date(installed_version)
        else
          @release_date_cache[name, installed_version]
        end
      end

      def libyears
        ::LibyearBundler::Calculators::Libyear.calculate(
          installed_version_release_date,
          self.class.newest_version_release_date
        )
      end

      def name
        'ruby'
      end

      # Simply delegates to class method, but we still need it to conform to
      # the interface expected by `Report#meta_line_summary`.
      def newest_version
        self.class.newest_version
      end

      # Simply delegates to class method, but we still need it to conform to
      # the interface expected by `Report#meta_line_summary`.
      def newest_version_release_date
        self.class.newest_version_release_date
      end

      def outdated?
        installed_version < newest_version
      end

      def version_number_delta
        ::LibyearBundler::Calculators::VersionNumberDelta.calculate(
          installed_version,
          self.class.newest_version
        )
      end

      def version_sequence_delta
        ::LibyearBundler::Calculators::VersionSequenceDelta.calculate(
          installed_version_sequence_index,
          self.class.newest_version_sequence_index
        )
      end

      private

      def installed_version_sequence_index
        self.class.all_stable_versions.index(installed_version.to_s)
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
          .new(::File.read(@lockfile))
          .ruby_version
        return if ruby_version_string.nil?
        ::Bundler::RubyVersion.from_string(ruby_version_string).gem_version
      end

      def version_from_ruby_version_file
        version_file = File.join(File.dirname(@lockfile), '.ruby-version')
        return unless File.exist?(version_file)

        version_string = File.read(version_file).strip
        version = version_string.split('-', 2).last

        ::Gem::Version.new(version) if version
      end

      def version_from_ruby
        ::Gem::Version.new(shell_out_to_ruby)
      end
    end
  end
end
