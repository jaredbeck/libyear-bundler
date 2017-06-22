module LibyearBundler
  # Responsible presenting data from the `Query`. Should only be concerned
  # with presentation, nothing else.
  class Report
    # `gems` - Array of hashes.
    def initialize(gems)
      @gems = gems
    end

    def to_s
      sum_years = 0.0
      sum_major_version = sum_minor_version = sum_patch_version = 0
      @gems.each do |gem|
        years = gem[:libyears]
        sum_years += years
        sum_major_version += gem[:version_number_delta][0]
        sum_minor_version += gem[:version_number_delta][1]
        sum_patch_version += gem[:version_number_delta][2]
        puts(
          format(
            "%30s%15s%15s%15s%15s%10.1f",
            gem[:name],
            gem[:installed][:version],
            gem[:installed][:date],
            gem[:newest][:version],
            gem[:newest][:date],
            years
          )
        )
      end
      puts format("System is %.1f libyears behind", sum_years)
      puts format("Major, minor, patch versions behind: %d, %d, %d",
        sum_major_version,
        sum_minor_version,
        sum_patch_version
      )
    end
  end
end
