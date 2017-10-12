require 'spec_helper'
require 'date'

module Calculators
  RSpec.describe Libyear do
    describe '#calculate' do
      it 'returns the time difference between gem releases in years' do
        installed_date = Date.new(2016, 1, 1)
        newest_date = Date.new(2017, 1, 1)
        gem_name = 'mock_gem'

        allow(described_class)
          .to receive(:release_date)
          .with(gem_name, '1.0')
          .and_return(installed_date)
        allow(described_class)
          .to receive(:release_date)
          .with(gem_name, '2.0')
          .and_return(newest_date)

        gem = {
          name: gem_name,
          installed: { version: '1.0', date: installed_date },
          newest: { version: '2.0', date: newest_date }
        }

        expect(described_class.calculate(gem)).to be_within(0.01).of(1.00)
      end
    end
  end
end
