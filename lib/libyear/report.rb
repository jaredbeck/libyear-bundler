module Libyear
  # Responsible presenting data from the `Query`. Should only be concerned
  # with presentation, nothing else.
  class Report
    # `gems` - Array of hashes.
    def initialize(gems)
      @gems = gems
    end

    def to_s
      sum_years = 0.0
      @gems.each do |gem|
        years = gem[:libyears]
        sum_years += years
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
    end
  end
end
