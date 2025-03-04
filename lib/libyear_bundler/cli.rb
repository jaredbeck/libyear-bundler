require "bundler/cli"
require "bundler/cli/outdated"
require "libyear_bundler/bundle_outdated"
require "libyear_bundler/options"
require "libyear_bundler/release_date_cache"
require "libyear_bundler/reports/console"
require "libyear_bundler/reports/json"
require 'libyear_bundler/models/ruby'

module LibyearBundler
  # The `libyear-bundler` command line program
  class CLI
    E_BUNDLE_OUTDATED_FAILED = 1
    E_NO_GEMFILE = 2
    E_INVALID_CLI_ARG = 3

    def initialize(argv)
      @options = ::LibyearBundler::Options.new(argv).parse
      # Command line flags are removed form `argv` in `Options` by
      # `OptionParser`, leaving non-flag command line arguments,
      # such as a Gemfile path
      @argv = argv
      @gemfile_path = load_gemfile_path
    end

    def run
      if @options.grand_total?
        grand_total
      else
        report.write
      end

      # Update cache
      cache_path = @options.cache_path
      if cache_path && release_date_cache
        release_date_cache.save(cache_path)
      end
    end

    private

    def first_arg_is_gemfile?
      !@argv.first.nil? && ::File.exist?(@argv.first)
    end

    def fallback_gemfile_exists?
      # The envvar is set or
      (!ENV["BUNDLE_GEMFILE"].nil? && ::File.exist?(ENV["BUNDLE_GEMFILE"])) ||
        # Default to local Gemfile
        ::File.exist?("Gemfile")
    end

    def load_gemfile_path
      if first_arg_is_gemfile?
        @argv.first
      elsif fallback_gemfile_exists?
        '' # `bundle outdated` will default to local Gemfile
      else
        $stderr.puts "Gemfile not found"
        exit E_NO_GEMFILE
      end
    end

    def bundle_outdated
      BundleOutdated.new(@gemfile_path, release_date_cache).execute
    end

    def release_date_cache
      @_release_date_cache ||= begin
        path = @options.cache_path
        return if path.nil?
        ReleaseDateCache.load(path)
      end
    end

    def report
      @_report ||= if @options.json?
        Reports::JSON.new(bundle_outdated, ruby, @options, $stdout)
      else
        Reports::Console.new(bundle_outdated, ruby, @options, $stdout)
      end
    end

    def ruby
      lockfile = @gemfile_path + '.lock'
      ::LibyearBundler::Models::Ruby.new(lockfile, release_date_cache)
    end

    def grand_total
      puts calculate_grand_total
    end

    def calculate_grand_total
      if [:libyears?, :releases?, :versions?].all? { |opt| @options[opt] }
        [
          libyears_grand_total,
          releases_grand_total,
          versions_grand_total
        ].join("\n")
      elsif @options.releases?
        releases_grand_total
      elsif @options.versions?
        versions_grand_total
      else
        libyears_grand_total
      end
    end

    def libyears_grand_total
      report.to_h[:sum_libyears].truncate(1)
    end

    def releases_grand_total
      report.to_h[:sum_seq_delta]
    end

    def versions_grand_total
      [
        report.to_h[:sum_major_version],
        report.to_h[:sum_minor_version],
        report.to_h[:sum_patch_version]
      ].to_s
    end
  end
end
