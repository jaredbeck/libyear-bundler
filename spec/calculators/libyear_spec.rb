require 'spec_helper'
require 'date'

module LibyearBundler
  module Calculators
    RSpec.describe Libyear do
      describe '#calculate' do
        it 'returns the time difference between gem releases in years' do
          installed_date = Date.new(2016, 1, 1)
          newest_date = Date.new(2017, 1, 1)

          expect(described_class.calculate(installed_date, newest_date))
            .to be_within(0.01).of(1.00)
        end
      end
    end
  end
end
