module LibyearBundler
  # Responsible presenting data from the `Query`. Should only be concerned
  # with presentation, nothing else.
  class Report
    # `gems` - Array of hashes.
    def initialize(gems, flags)
      @gems = gems
      @flags = flags
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
      meta = meta_gem_summary(gem)
      libyear = format("%10.1f", gem[:libyears])
      releases = format("%10d", gem[:version_sequence_delta])
      versions = format("%15s", gem[:version_number_delta])

      if @flags.include?("--releases")
        puts meta << releases
      elsif @flags.include?("--versions")
        puts meta << versions
      elsif @flags.include?("--all")
        puts meta << libyear << releases << versions
      else
        puts meta << libyear
      end
    end

    def meta_gem_summary(gem)
      format(
        "%30s%15s%15s%15s%15s",
        gem[:name],
        gem[:installed][:version],
        gem[:installed][:date],
        gem[:newest][:version],
        gem[:newest][:date]
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
      if @flags.include?("--versions")
        put_version_delta_summary(
          summary[:sum_major_version],
          summary[:sum_minor_version],
          summary[:sum_patch_version]
        )
      elsif @flags.include?("--releases")
        put_sum_seq_delta_summary(summary[:sum_seq_delta])
      elsif @flags.include?("--all")
        put_libyear_summary(summary[:sum_years])
        put_sum_seq_delta_summary(summary[:sum_seq_delta])
        put_version_delta_summary(
          summary[:sum_major_version],
          summary[:sum_minor_version],
          summary[:sum_patch_version]
        )
      else
        put_libyear_summary(summary[:sum_years])
      end
    end
  end
end
