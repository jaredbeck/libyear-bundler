module Calculators
  # A libyear is the difference in time between releases of the newest and
  # installed versions of the gem in years
  class Libyear
    class << self
      def calculate(gem)
        di = release_date(gem[:name], gem[:installed][:version])
        dn = release_date(gem[:name], gem[:newest][:version])
        gem[:installed][:date] = di
        gem[:newest][:date] = dn
        if di.nil? || dn.nil? || dn <= di
          # Known issue: Backports and maintenance releases of older minor versions.
          # Example: json 1.8.6 (2017-01-13) was released *after* 2.0.3 (2017-01-12)
          years = 0.0
        else
          days = (dn - di).to_f
          years = days / 365.0
        end
        years
      end

      private

      # Known issue: Probably performs a network request every time, unless
      # there's some kind of caching.
      def release_date(gem_name, gem_version)
        dep = nil
        begin
          dep = ::Bundler::Dependency.new(gem_name, gem_version)
        rescue ::Gem::Requirement::BadRequirementError => e
          $stderr.puts "Could not find release date for: #{gem_name}"
          $stderr.puts(e)
          $stderr.puts(
            "Maybe you used git in your Gemfile, which libyear doesn't support " \
            "yet. Contributions welcome."
          )
          return nil
        end
        tuples, _errors = ::Gem::SpecFetcher.fetcher.search_for_dependency(dep)
        if tuples.empty?
          $stderr.puts "Could not find release date for: #{gem_name}"
          return nil
        end
        tup, source = tuples.first # Gem::NameTuple
        spec = source.fetch_spec(tup) # raises Gem::RemoteFetcher::FetchError
        spec.date.to_date
      end
    end
  end
end
