module Calculators
  class VersionNumberDelta
    class << self
      def calculate(gem)
        newest_version_tuple = version_tuple(gem[:newest][:version].split('.'))
        installed_version_tuple = version_tuple(gem[:installed][:version].split('.'))
        major_version_delta = version_delta(newest_version_tuple.major, installed_version_tuple.major)
        minor_version_delta = version_delta(newest_version_tuple.minor, installed_version_tuple.minor)
        patch_version_delta = version_delta(newest_version_tuple.patch, installed_version_tuple.patch)
        [major_version_delta, minor_version_delta, patch_version_delta]
      end

      private

      def version_delta(newest_version, installed_version)
        delta = newest_version - installed_version
        delta < 0 ? 0 : delta
      end

      def version_tuple(version_array)
        version_struct = Struct.new(:major, :minor, :patch)
        version_struct.new(
          version_array[0].to_i,
          version_array[1].to_i,
          version_array[2].to_i
        )
      end
    end
  end
end
