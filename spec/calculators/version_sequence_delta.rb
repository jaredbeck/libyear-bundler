require 'spec_helper'

module Calculators
  RSpec.describe VersionSequenceDelta do
    describe '#calculate' do
      it 'returns the number of releases between the newest and installed versions' do
        gem = {
          name: 'mock_gem',
          installed: { version: '1.0.0' },
          newest: { version: '3.0.0' }
        }

        allow(described_class)
          .to receive(:gem_version_details)
          .with(gem[:name])
          .and_return(
            [
              { 'number' => '3.0.0' },
              { 'number' => '2.0.0' },
              { 'number' => '1.0.0' }
            ]
          )

        expect(described_class.calculate(gem)).to eq(2)
      end
    end
  end
end
