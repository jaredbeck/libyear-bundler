require 'spec_helper'

module LibyearBundler
  module Calculators
    RSpec.describe VersionNumberDelta do
      describe '#calculate' do
        it 'returns the difference in version numbers between releases' do
          installed_version = '1.0.0'
          newest_version = '2.0.0'

          expect(described_class.calculate(installed_version, newest_version))
            .to eq([1, 0, 0])
        end

        context 'major, minor, and patch numbers are different' do
          it 'returns the major version difference' do
            installed_version = '1.1.1'
            newest_version = '2.2.2'

            expect(described_class.calculate(installed_version, newest_version))
              .to eq([1, 0, 0])
          end
        end

        context 'minor and patch numbers are different' do
          it 'returns the minor version difference' do
            installed_version = '1.1.1'
            newest_version = '1.2.2'

            expect(described_class.calculate(installed_version, newest_version))
              .to eq([0, 1, 0])
          end
        end

        context 'patch numbers are different' do
          it 'returns the patch version difference' do
            installed_version = '1.1.1'
            newest_version = '1.1.2'

            expect(described_class.calculate(installed_version, newest_version))
              .to eq([0, 0, 1])
          end
        end

        context 'new minor and patch version numbers are lower' do
          it 'returns the major version difference' do
            installed_version = '1.2.2'
            newest_version = '2.1.1'

            expect(described_class.calculate(installed_version, newest_version))
              .to eq([1, 0, 0])
          end
        end
      end
    end
  end
end
