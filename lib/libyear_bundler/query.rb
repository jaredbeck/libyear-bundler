require "English"
require "open3"

module LibyearBundler
  # Responsible for getting all the data that goes into the `Report`.
  class Query
    # Format of `bundle outdated --parseable` (BOP)
    BOP_FMT = /\A(?<name>[^ ]+) \(newest (?<newest>[^,]+), installed (?<installed>[^,)]+)/

    def initialize(gemfile_path)
      @gemfile_path = gemfile_path
    end

    def execute
      gems = []
      bundle_outdated.lines.each do |line|
        match = BOP_FMT.match(line)
        next if match.nil?
        gems.push(
          installed: { version: match["installed"] },
          name: match["name"],
          newest: { version: match["newest"] }
        )
      end
      gems.each do |gem|
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
        gem[:libyears] = years
      end
      gems
    end

    private

    def bundle_outdated
      stdout, stderr, status = Open3.capture3(
        %Q(BUNDLE_GEMFILE="#{@gemfile_path}" bundle outdated --parseable)
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
        Kernel.exit(1)
      end
      stdout
    end

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
