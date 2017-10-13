require 'spec_helper'

module Calculators
  RSpec.describe VersionNumberDelta do
    describe '#calculate' do
      it 'returns the difference in version numbers between releases' do
        gem = {
          name: 'mock_gem',
          installed: { version: '1.0' },
          newest: { version: '2.0' }
        }

        expect(described_class.calculate(gem)).to eq([1, 0, 0])
      end

      context 'major, minor, and patch numbers are different' do
        it 'returns the major version difference' do
          gem = {
            name: 'mock_gem',
            installed: { version: '1.1.1' },
            newest: { version: '2.2.2' }
          }

          expect(described_class.calculate(gem)).to eq([1, 0, 0])
        end
      end

      context 'minor and patch numbers are different' do
        it 'returns the minor version difference' do
          gem = {
            name: 'mock_gem',
            installed: { version: '1.1.1' },
            newest: { version: '1.2.2' }
          }

          expect(described_class.calculate(gem)).to eq([0, 1, 0])
        end
      end

      context 'patch numbers are different' do
        it 'returns the patch version difference' do
          gem = {
            name: 'mock_gem',
            installed: { version: '1.1.1' },
            newest: { version: '1.1.2' }
          }

          expect(described_class.calculate(gem)).to eq([0, 0, 1])
        end
      end

      context 'new minor and patch version numbers are lower' do
        it 'returns the major version difference' do
          gem = {
            name: 'mock_gem',
            installed: { version: '1.2.2' },
            newest: { version: '2.1.1' }
          }

          expect(described_class.calculate(gem)).to eq([1, 0, 0])
        end
      end
    end
  end
end
