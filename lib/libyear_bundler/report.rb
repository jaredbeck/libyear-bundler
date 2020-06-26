module LibyearBundler
  # Responsible presenting data from the `::LibyearBundler::Models`. Should only
  # be concerned with presentation, nothing else.
  class Report
    FMT_LIBYEARS_COLUMN = "%10.1f".freeze
    FMT_RELEASES_COLUMN = "%10d".freeze
    FMT_VERSIONS_COLUMN = "%15s".freeze
    FMT_SUMMARY_COLUMNS = "%30s%15s%15s%15s%15s".freeze

    # `gems` - Array of `::LibyearBundler::Models::Gem` instances
    # `options` - Instance of `::LibyearBundler::Options`
    def initialize(gems, ruby, options)
      @gems = gems
      @ruby = ruby
      @options = options
    end

    def to_s
      to_h[:gems].each { |gem| put_line_summary(gem) }

      begin
        put_line_summary(@ruby) if @ruby.outdated?
      rescue StandardError => e
        warn "Unable to calculate libyears for ruby itself: #{e} (line summary)"
      end

      put_summary(to_h)
    end

    def to_h
      @_to_h ||=
        begin
          summary = {
            gems: @gems,
            sum_libyears: 0.0
          }
          @gems.each { |gem| increment_metrics_summary(gem, summary) }

          begin
            increment_metrics_summary(@ruby, summary) if @ruby.outdated?
          rescue StandardError => e
            warn "Unable to calculate libyears for ruby itself: #{e}"
          end

          summary
        end
    end

    private

    def increment_metrics_summary(model, summary)
      increment_libyears(model, summary) if @options.libyears?
      increment_version_deltas(model, summary) if @options.versions?
      increment_seq_deltas(model, summary) if @options.releases?
    end

    def put_line_summary(gem_or_ruby)
      meta = meta_line_summary(gem_or_ruby)

      if @options.releases?
        releases = format(FMT_RELEASES_COLUMN, gem_or_ruby.version_sequence_delta)
        meta << releases
      end

      if @options.versions?
        versions = format(FMT_VERSIONS_COLUMN, gem_or_ruby.version_number_delta)
        meta << versions
      end

      if @options.libyears?
        libyears = format(FMT_LIBYEARS_COLUMN, gem_or_ruby.libyears)
        meta << libyears
      end

      puts meta
    end

    def meta_line_summary(gem_or_ruby)
      format(
        FMT_SUMMARY_COLUMNS,
        gem_or_ruby.name,
        gem_or_ruby.installed_version.to_s,
        gem_or_ruby.installed_version_release_date,
        gem_or_ruby.newest_version.to_s,
        gem_or_ruby.newest_version_release_date
      )
    end

    def put_libyear_summary(sum_libyears)
      puts format("System is %.1f libyears behind", sum_libyears)
    end

    def put_version_delta_summary(sum_major_version, sum_minor_version, sum_patch_version)
      puts format(
        "Major, minor, patch versions behind: %<major>d, %<minor>d, %<patch>d",
        major: sum_major_version || 0,
        minor: sum_minor_version || 0,
        patch: sum_patch_version || 0
      )
    end

    def put_sum_seq_delta_summary(sum_seq_delta)
      puts format(
        "Total releases behind: %<seq_delta>d",
        seq_delta: sum_seq_delta || 0
      )
    end

    def put_summary(summary)
      if [:libyears?, :releases?, :versions?].all? { |opt| @options.send(opt) }
        put_libyear_summary(summary[:sum_libyears])
        put_sum_seq_delta_summary(summary[:sum_seq_delta])
        put_version_delta_summary(
          summary[:sum_major_version],
          summary[:sum_minor_version],
          summary[:sum_patch_version]
        )
      elsif @options.versions?
        put_version_delta_summary(
          summary[:sum_major_version],
          summary[:sum_minor_version],
          summary[:sum_patch_version]
        )
      elsif @options.releases?
        put_sum_seq_delta_summary(summary[:sum_seq_delta])
      elsif @options.libyears?
        put_libyear_summary(summary[:sum_libyears])
      end
    end

    def increment_libyears(model, memo)
      memo[:sum_libyears] += model.libyears
    end

    def increment_seq_deltas(model, memo)
      memo[:sum_seq_delta] ||= 0
      memo[:sum_seq_delta] += model.version_sequence_delta
    end

    def increment_version_deltas(model, memo)
      memo[:sum_major_version] ||= 0
      memo[:sum_major_version] += model.version_number_delta[0]
      memo[:sum_minor_version] ||= 0
      memo[:sum_minor_version] += model.version_number_delta[1]
      memo[:sum_patch_version] ||= 0
      memo[:sum_patch_version] += model.version_number_delta[2]
    end
  end
end
