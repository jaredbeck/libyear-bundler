require "English"
require "open3"
require 'libyear_bundler/calculators/libyear'
require 'libyear_bundler/calculators/version_number_delta'
require 'libyear_bundler/calculators/version_sequence_delta'
require 'libyear_bundler/models/gem'

module LibyearBundler
  # Responsible for getting all the data that goes into the `Report`.
  class Query
    # Format of `bundle outdated --parseable` (BOP)
    BOP_FMT = /\A(?<name>[^ ]+) \(newest (?<newest>[^,]+), installed (?<installed>[^,)]+)/

    def initialize(gemfile_path)
      @gemfile_path = gemfile_path
    end

    def execute
      bundle_outdated.lines.each_with_object([]) do |line, gems|
        match = BOP_FMT.match(line)
        next if match.nil?
        gem = ::LibyearBundler::Models::Gem.new(
          match['name'],
          match['installed_version'],
          match['newest_version']
        )
        gems.push(gem)
      end
    end

    private

    def bundle_outdated
      stdout, stderr, status = Open3.capture3(
        %(BUNDLE_GEMFILE="#{@gemfile_path}" bundle outdated --parseable)
      )
      # Known statuses:
      # 0 - Nothing is outdated
      # 256 - Something is outdated
      # 1792 - Unable to determine if something is outdated
      unless [0, 256].include?(status.to_i)
        $stderr.puts "`bundle outdated` failed with status: #{status.to_i}"
        $stderr.puts "stderr: #{stderr}"
        $stderr.puts "stdout: #{stdout}"
        $stderr.puts "Try running `bundle install`."
        Kernel.exit(CLI::E_BUNDLE_OUTDATED_FAILED)
      end
      stdout
    end
  end
end
