require 'yaml'

module LibyearBundler
  # A cache of release dates by name and version, for both gems and rubies.
  class ReleaseDateCache
    # @param data [Hash<String,Date>]
    def initialize(data)
      raise TypeError unless data.is_a?(Hash)
      @data = data
    end

    def [](name, version)
      key = format('%s-%s', name, version)
      if @data.key?(key)
        @data[key]
      else
        @data[key] = release_date(name, version)
      end
    end

    class << self
      def load(path)
        if File.exist?(path)
          new(YAML.safe_load(File.read(path), [Date]))
        else
          new({})
        end
      end
    end

    def save(path)
      content = YAML.dump(@data)
      begin
        File.write(path, content)
      rescue StandardError => e
        warn format('Unable to update cache: %s, %s', path, e.message)
      end
    end

    private

    def release_date(name, version)
      if name == 'ruby'
        Models::Ruby.release_date(version)
      else
        Models::Gem.release_date(name, version)
      end
    end
  end
end
