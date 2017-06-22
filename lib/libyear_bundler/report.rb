module LibyearBundler
  # Responsible presenting data from the `Query`. Should only be concerned
  # with presentation, nothing else.
  class Report
    # `gems` - Array of hashes.
    def initialize(gems)
      @gems = gems
    end

    def to_s
      summary = {
        sum_years: 0.0,
        sum_major_version: 0,
        sum_minor_version: 0,
        sum_patch_version: 0,
        sum_seq_delta: 0
      }
      @gems.each do |gem|
        summary[:sum_years] += gem[:libyears]
        summary[:sum_major_version] += gem[:version_number_delta][0]
        summary[:sum_minor_version] += gem[:version_number_delta][1]
        summary[:sum_patch_version] += gem[:version_number_delta][2]
        summary[:sum_seq_delta] += gem[:version_sequence_delta]
        put_gem_summary(gem)
      end
      put_summary(summary)
    end

    private

    def put_gem_summary(gem)
      puts(
        format(
          "%30s%15s%15s%15s%15s%10.1f [%d,%d,%d] %d",
          gem[:name],
          gem[:installed][:version],
          gem[:installed][:date],
          gem[:newest][:version],
          gem[:newest][:date],
          gem[:libyears],
          gem[:version_number_delta][0],
          gem[:version_number_delta][1],
          gem[:version_number_delta][2],
          gem[:version_sequence_delta]
        )
      )
    end

    def put_libyear_summary(sum_years)
      puts format("System is %.1f libyears behind", sum_years)
    end

    def put_version_delta_summary(sum_major_version, sum_minor_version, sum_patch_version)
      puts format(
        "Major, minor, patch versions behind: %d, %d, %d",
        sum_major_version,
        sum_minor_version,
        sum_patch_version
      )
    end

    def put_sum_seq_delta_summary(sum_seq_delta)
      puts format("Total releases behind: %d", sum_seq_delta)
    end

    def put_summary(summary)
      put_libyear_summary(summary[:sum_years])
      put_version_delta_summary(
        summary[:sum_major_version],
        summary[:sum_minor_version],
        summary[:sum_patch_version]
      )
      put_sum_seq_delta_summary(summary[:sum_seq_delta])
    end
  end
end
