require "bundler/cli"
require "bundler/cli/outdated"
require "libyear_bundler/report"
require "libyear_bundler/query"
require "libyear_bundler/options"

module LibyearBundler
  # The `libyear-bundler` command line program
  class CLI
    E_BUNDLE_OUTDATED_FAILED = 1
    E_NO_GEMFILE = 2

    def initialize(argv)
      @options = ::LibyearBundler::Options.new(argv).parse!
      @argv = argv # `parse_argv` removes non-flag options, leaving e.g. a Gemfile path
      @gemfile_path = load_gemfile_path
    end

    def run
      if @options[:grand_total?]
        grand_total
      else
        print report.to_s
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
        exit
      end
    end

    def query
      Query.new(@gemfile_path).execute
    end

    def report
      @_report ||= Report.new(query, @options)
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
      elsif @options[:releases?]
        releases_grand_total
      elsif @options[:versions?]
        versions_grand_total
      else
        libyears_grand_total
      end
    end

    def libyears_grand_total
      report.to_h[:sum_years].truncate(1)
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
