module LibyearBundler
  module Reports
    # Base class for all reporters. Should only be concerned with presentation, nothing else.
    #
    # Subclasses should implement the `#write` method.
    class Base
      # `gems` - Array of `::LibyearBundler::Models::Gem` instances
      # `options` - Instance of `::LibyearBundler::Options`
      def initialize(gems, ruby, options, io)
        @gems = gems
        @ruby = ruby
        @options = options
        @io = io
      end

      def write
        raise NoMethodError, "Implement in subclass"
      end

      def to_h
        @_to_h ||=
          begin
            gems = sorted_gems(@gems)
            summary = {
              gems: gems,
              sum_libyears: 0.0
            }
            gems.each { |gem| increment_metrics_summary(gem, summary) }

            begin
              increment_metrics_summary(@ruby, summary) if @ruby.outdated?
            rescue StandardError => e
              warn "Unable to calculate libyears for ruby itself: #{e}"
            end

            summary
          end
      end

      private

      def sorted_gems(gems)
        if @options.sort?
          gems.sort_by do |gem|
            [
              (gem.libyears if @options.libyears?),
              (gem.version_sequence_delta if @options.releases?),
              (gem.version_number_delta if @options.versions?)
            ].compact
          end.reverse
        else
          gems
        end
      end

      def increment_metrics_summary(model, summary)
        increment_libyears(model, summary) if @options.libyears?
        increment_version_deltas(model, summary) if @options.versions?
        increment_seq_deltas(model, summary) if @options.releases?
      end

      def increment_libyears(model, memo)
        memo[:sum_libyears] += model.libyears
      rescue StandardError => e
        warn "Unable to calculate libyears for #{model.name}: #{e}"
      end

      def increment_seq_deltas(model, memo)
        memo[:sum_seq_delta] ||= 0
        memo[:sum_seq_delta] += model.version_sequence_delta
      rescue StandardError => e
        warn "Unable to calculate seq deltas for #{model.name}: #{e}"
      end

      def increment_version_deltas(model, memo)
        memo[:sum_major_version] ||= 0
        memo[:sum_major_version] += model.version_number_delta[0]
        memo[:sum_minor_version] ||= 0
        memo[:sum_minor_version] += model.version_number_delta[1]
        memo[:sum_patch_version] ||= 0
        memo[:sum_patch_version] += model.version_number_delta[2]
      rescue StandardError => e
        warn "Unable to calculate version deltas for #{model.name}: #{e}"
      end
    end
  end
end
