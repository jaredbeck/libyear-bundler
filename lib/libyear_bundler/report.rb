module LibyearBundler
  # Responsible presenting data from the `Query`. Should only be concerned
  # with presentation, nothing else.
  class Report
    FMT_RELEASES_COLUMN = "%10d".freeze
    FMT_VERSIONS_COLUMN = "%15s".freeze

    # `gems` - Array of hashes.
    def initialize(gems)
      @gems = gems
    end

    def to_s
      to_h[:gems].each { |gem| put_gem_summary(gem) }
      put_summary(to_h)
    end

    def to_h
      @_to_h ||=
        begin
          summary = {
            gems: @gems,
            sum_years: 0.0
          }
          @gems.each_with_object(summary) do |gem, memo|
            memo[:sum_years] += gem.libyears

            if !gem.version_number_delta.nil?
              memo[:sum_major_version] ||= 0
              memo[:sum_major_version] += gem.version_number_delta[0]
              memo[:sum_minor_version] ||= 0
              memo[:sum_minor_version] += gem.version_number_delta[1]
              memo[:sum_patch_version] ||= 0
              memo[:sum_patch_version] += gem.version_number_delta[2]
            end

            if !gem.version_sequence_delta.nil?
              memo[:sum_seq_delta] ||= 0
              memo[:sum_seq_delta] += gem.version_sequence_delta
            end
          end
        end
    end

    private

    def put_gem_summary(gem)
      meta = meta_gem_summary(gem)
      libyear = format("%10.1f", gem.libyears)

      if !gem.version_sequence_delta.nil? && !gem.version_number_delta.nil?
        releases = format(FMT_RELEASES_COLUMN, gem.version_sequence_delta)
        versions = format(FMT_VERSIONS_COLUMN, gem.version_number_delta)
        puts meta << libyear << releases << versions
      elsif !gem.version_sequence_delta.nil?
        releases = format(FMT_RELEASES_COLUMN, gem.version_sequence_delta)
        puts meta << releases
      elsif !gem.version_number_delta.nil?
        versions = format(FMT_VERSIONS_COLUMN, gem.version_number_delta)
        puts meta << versions
      else
        puts meta << libyear
      end
    end

    def meta_gem_summary(gem)
      format(
        "%30s%15s%15s%15s%15s",
        gem.name,
        gem.installed_version.to_s,
        gem.installed_version_release_date,
        gem.newest_version.to_s,
        gem.newest_version_release_date
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
      if summary.key?(:sum_seq_delta) && summary.key?(:sum_major_version)
        put_libyear_summary(summary[:sum_years])
        put_sum_seq_delta_summary(summary[:sum_seq_delta])
        put_version_delta_summary(
          summary[:sum_major_version],
          summary[:sum_minor_version],
          summary[:sum_patch_version]
        )
      elsif summary.key?(:sum_major_version)
        put_version_delta_summary(
          summary[:sum_major_version],
          summary[:sum_minor_version],
          summary[:sum_patch_version]
        )
      elsif summary.key?(:sum_seq_delta)
        put_sum_seq_delta_summary(summary[:sum_seq_delta])
      else
        put_libyear_summary(summary[:sum_years])
      end
    end
  end
end
