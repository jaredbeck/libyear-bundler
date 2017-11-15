module LibyearBundler
  module Calculators
    # The version sequence delta is the number of releases between the newest and
    # installed versions of the gem
    class VersionSequenceDelta
      class << self
        def calculate(installed_seq_index, newest_seq_index)
          installed_seq_index - newest_seq_index
        end
      end
    end
  end
end
