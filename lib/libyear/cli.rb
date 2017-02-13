require "bundler/cli"
require "bundler/cli/outdated"

module Libyear
  class CLI
    # Format of `bundle outdated --parseable` (BOP)
    BOP_FMT = /\A(?<name>[^ ]+) \(newest (?<newest>[^,]+), installed (?<installed>[^,)]+)/

    def initialize(argv)
      validate_arguments(argv)
      @gemfile_path = argv.first
    end

    def run
      parseable = `BUNDLE_GEMFILE="#{@gemfile_path}" bundle outdated --parseable`
      gems = []
      parseable.lines.each do |line|
        match = BOP_FMT.match(line)
        next if match.nil?
        gems.push(
          installed: { version: match["installed"] },
          name: match["name"],
          newest: { version: match["newest"] }
        )
      end
      gems.each do |gem|
        gem[:installed][:date] = release_date(gem[:name], gem[:installed][:version])
        gem[:newest][:date] = release_date(gem[:name], gem[:newest][:version])
      end
      report(gems)
    end

    private

    # Known issue: Probably performs a network request every time, unless
    # there's some kind of caching.
    def release_date(gem_name, gem_version)
      dep = ::Bundler::Dependency.new(gem_name, gem_version)
      tuples, _errors = ::Gem::SpecFetcher.fetcher.search_for_dependency(dep)
      tup, source = tuples.first # Gem::NameTuple
      spec = source.fetch_spec(tup) # raises Gem::RemoteFetcher::FetchError
      spec.date.to_date
    end

    def report(gems)
      sum_years = 0.0
      gems.each do |gem|
        di = gem[:installed][:date]
        dn = gem[:newest][:date]
        if dn <= di
          # Known issue: Backports and maintenance releases of older minor versions.
          # Example: json 1.8.6 (2017-01-13) was released *after* 2.0.3 (2017-01-12)
          years = 0.0
        else
          days = (dn - di).to_f
          years = days / 365.0
        end
        sum_years += years
        puts(
          format(
            "%20s%10s%15s%10s%15s%10.1f",
            gem[:name],
            gem[:installed][:version],
            di,
            gem[:newest][:version],
            dn,
            years
          )
        )
      end
      puts format("System is %.1f libyears behind", sum_years)
    end

    def validate_arguments(argv)
      # todo
    end
  end
end
