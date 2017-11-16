require 'spec_helper'

module LibyearBundler
  module Calculators
    RSpec.describe VersionSequenceDelta do
      describe '#calculate' do
        it 'returns the number of releases between the newest and installed versions' do
          installed_version_sequence_index = 3
          newest_version_sequence_index = 1

          calculation = described_class.calculate(
            installed_version_sequence_index,
            newest_version_sequence_index
          )
          expect(calculation).to eq(2)
        end
      end
    end
  end
end
