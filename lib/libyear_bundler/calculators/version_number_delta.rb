module LibyearBundler
  module Calculators
    # The version number delta is the absolute difference between the highest-
    # order version number of the installed and newest releases
    class VersionNumberDelta
      class << self
        def calculate(installed_version, newest_version)
          installed_version_tuple = version_tuple(installed_version.to_s.split('.'))
          newest_version_tuple = version_tuple(newest_version.to_s.split('.'))
          major_version_delta = version_delta(
            newest_version_tuple.major, installed_version_tuple.major
          )
          minor_version_delta = version_delta(
            newest_version_tuple.minor, installed_version_tuple.minor
          )
          patch_version_delta = version_delta(
            newest_version_tuple.patch, installed_version_tuple.patch
          )
          highest_order([major_version_delta, minor_version_delta, patch_version_delta])
        end

        private

        def highest_order(arr)
          arr[1] = arr[2] = 0 if arr[0] > 0
          arr[2] = 0 if arr[1] > 0
          arr
        end

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
end
