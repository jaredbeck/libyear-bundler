require 'spec_helper'

module Calculators
  RSpec.describe VersionSequenceDelta do
    describe '#calculate' do
      it 'returns the number of releases between the newest and installed versions' do
        gem_name = 'mock_gem'
        installed_version = '1.0.0'
        newest_version = '3.0.0'

        allow(described_class)
          .to receive(:gem_version_details)
          .with(gem_name)
          .and_return(
            [
              { 'number' => newest_version },
              { 'number' => '2.0.0' },
              { 'number' => installed_version }
            ]
          )

        calculation = described_class.calculate(
          gem_name,
          installed_version,
          newest_version
        )
        expect(calculation).to eq(2)
      end
    end
  end
end
