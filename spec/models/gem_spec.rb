require 'spec_helper'

module LibyearBundler
  module Models
    RSpec.describe Gem do
      describe '#installed_version' do
        it 'returns the installed version' do
          newest_version = '1.0.0'
          gem = described_class.new(nil, newest_version, nil)
          expect(gem.installed_version).to eq(::Gem::Version.new(newest_version))
        end
      end

      describe '#installed_version_release_date' do
        it 'returns the release date of the installed version' do
          date = Date.new(2017, 1, 1)
          gem = described_class.new(nil, nil, nil)
          allow(gem).to receive(:release_date).and_return(date)
          expect(gem.installed_version_release_date).to eq(date)
        end
      end

      describe '#installed_version_sequence_index' do
        it 'returns the index' do
          installed_version = '1.0.0'
          newest_version = '2.0.0'
          gem = described_class.new(nil, installed_version, newest_version)
          allow(gem)
            .to receive(:versions_sequence)
            .and_return([newest_version, installed_version])
          expect(gem.installed_version_sequence_index).to eq(1)
        end
      end

      describe '#libyears' do
        it 'returns the number of years out of date' do
          allow(::LibyearBundler::Calculators::Libyear)
            .to receive(:calculate)
            .and_return(1)
          gem = described_class.new(nil, nil, nil)
          allow(gem).to receive(:libyears).and_return(1)
        end
      end

      describe '#name' do
        it 'returns the gem name' do
          gem_name = 'gem_name'
          gem = described_class.new(gem_name, nil, nil)
          expect(gem.name).to eq(gem_name)
        end
      end

      describe '#newest_version' do
        it 'returns the newest version' do
          newest_version = '2.0.0'
          gem = described_class.new(nil, nil, newest_version)
          expect(gem.newest_version).to eq(::Gem::Version.new(newest_version))
        end
      end

      describe '#newest_version_release_date' do
        it 'returns the release date of the newest version' do
          date = Date.new(2017, 1, 1)
          gem = described_class.new(nil, nil, nil)
          allow(gem).to receive(:release_date).and_return(date)
          expect(gem.newest_version_release_date).to eq(date)
        end
      end

      describe '#newest_version_sequence_index' do
        it 'returns the index' do
          installed_version = '1.0.0'
          newest_version = '2.0.0'
          gem = described_class.new(nil, installed_version, newest_version)
          allow(gem)
            .to receive(:versions_sequence)
            .and_return([newest_version, installed_version])
          expect(gem.newest_version_sequence_index).to eq(0)
        end
      end

      describe '#version_number_delta' do
        it 'returns an array of the major, minor, and patch versions out-of-date' do
          gem = described_class.new(nil, '1.0.0', '2.0.0')
          expect(gem.version_number_delta).to eq([1, 0, 0])
        end
      end

      describe '#version_sequence_delta' do
        it 'returns the number of releases between versions' do
          installed_version = '1.0.0'
          newest_version = '2.0.0'
          gem = described_class.new(nil, installed_version, newest_version)
          allow(gem)
            .to receive(:versions_sequence)
            .and_return([newest_version, installed_version])
          expect(gem.version_sequence_delta).to eq(1)
        end
      end
    end
  end
end
