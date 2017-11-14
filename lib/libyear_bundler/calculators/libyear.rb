module Calculators
  # A libyear is the difference in time between releases of the newest and
  # installed versions of the gem in years
  class Libyear
    class << self
      def calculate(installed_version_release_date, newest_version_release_date)
        di = installed_version_release_date
        dn = newest_version_release_date
        if di.nil? || dn.nil? || dn <= di
          # Known issue: Backports and maintenance releases of older minor versions.
          # Example: json 1.8.6 (2017-01-13) was released *after* 2.0.3 (2017-01-12)
          years = 0.0
        else
          days = (dn - di).to_f
          years = days / 365.0
        end
        years
      end
    end
  end
end
