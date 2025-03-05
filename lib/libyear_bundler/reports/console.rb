require "libyear_bundler/reports/base"

module LibyearBundler
  module Reports
    # Responsible presenting data from the `::LibyearBundler::Models`. Should only
    # be concerned with presentation, nothing else.
    class Console < Base
      FMT_LIBYEARS_COLUMN = "%10.1f".freeze
      FMT_RELEASES_COLUMN = "%10d".freeze
      FMT_VERSIONS_COLUMN = "%15s".freeze
      FMT_SUMMARY_COLUMNS = "%30s%15s%15s%15s%15s".freeze

      def write
        to_h[:gems].each { |gem| put_line_summary(gem) }

        begin
          put_line_summary(@ruby) if @ruby.outdated?
        rescue StandardError => e
          warn "Unable to calculate libyears for ruby itself: #{e} (line summary)"
        end

        put_summary(to_h)
      end

      private

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

        @io.puts meta
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
        @io.puts format("System is %.1f libyears behind", sum_libyears)
      end

      def put_version_delta_summary(sum_major_version, sum_minor_version, sum_patch_version)
        @io.puts format(
          "Major, minor, patch versions behind: %<major>d, %<minor>d, %<patch>d",
          major: sum_major_version || 0,
          minor: sum_minor_version || 0,
          patch: sum_patch_version || 0
        )
      end

      def put_sum_seq_delta_summary(sum_seq_delta)
        @io.puts format(
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
    end
  end
end
