require "bundler/cli"
require "bundler/cli/outdated"
require "libyear_bundler/report"
require "libyear_bundler/query"

module LibyearBundler
  # The `libyear-bundler` command line program
  class CLI
    OPTIONS = %w[
      --all
      --grand-total
      --libyears
      --releases
      --versions
    ].freeze

    E_BUNDLE_OUTDATED_FAILED = 1
    E_NO_GEMFILE = 2

    def initialize(argv)
      @argv = argv
      @gemfile_path = load_gemfile_path
      validate_arguments
    end

    def run
      if @argv.include?("--grand-total")
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
      @_report ||= Report.new(query, @argv)
    end

    def unexpected_options
      @_unexpected_options ||= begin
        options = @argv.select { |arg| arg.start_with?("--") }
        options.each_with_object([]) do |arg, memo|
          memo << arg unless OPTIONS.include?(arg)
        end
      end
    end

    def validate_arguments
      return if unexpected_options.empty?
      puts "Unexpected args: #{unexpected_options.join(', ')}"
      puts "Allowed args: #{OPTIONS.join(', ')}"
      exit E_NO_GEMFILE
    end

    def grand_total
      grand_total = if @argv.include?("--releases")
                      releases_grand_total
                    elsif @argv.include?("--versions")
                      versions_grand_total
                    elsif @argv.include?("--all")
                      "#{libyears_grand_total}\n#" \
                      "{releases_grand_total}\n#" \
                      "{versions_grand_total}"
                    else
                      libyears_grand_total
                    end

      puts grand_total
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
