require 'spec_helper'

module LibyearBundler
  module Models
    RSpec.describe Ruby do
      describe '#installed_version' do
        it 'gets the version from bundler' do
          ruby_version = '2.4.2'
          ruby = described_class.new(nil)
          allow(ruby).to receive(:version_from_bundler).and_return(ruby_version)
          expect(ruby.installed_version).to eq(ruby_version)
        end

        it 'gets the version from .ruby-version file' do
          ruby_version = '2.4.2'
          ruby = described_class.new(nil)
          allow(ruby).to receive(:version_from_bundler).and_return(nil)
          allow(ruby).to receive(:version_from_ruby_version_file).and_return(ruby_version)
          expect(ruby.installed_version).to eq(ruby_version)
        end

        it 'gets the version from ruby' do
          ruby_version = '2.4.2'
          ruby = described_class.new(nil)
          allow(ruby).to receive(:version_from_bundler).and_return(nil)
          allow(ruby).to receive(:version_from_ruby_version_file).and_return(nil)
          allow(ruby).to receive(:version_from_ruby).and_return(ruby_version)
          expect(ruby.installed_version).to eq(ruby_version)
        end
      end

      describe '#installed_version_release_date' do
        it 'returns the release date for the installed version' do
          date = Date.new(2017, 1, 1)
          ruby = described_class.new(nil)
          allow(ruby)
            .to receive(:release_date)
            .and_return(date)
          allow(ruby).to receive(:installed_version)
          expect(ruby.installed_version_release_date).to eq(date)
        end
      end

      describe '#libyears' do
        it 'returns the number of years out-of-date' do
          installed_version_release_date = Date.new(2017, 1, 1)
          newest_version_release_date = Date.new(2018, 1, 1)
          ruby = described_class.new(nil)
          allow(ruby)
            .to receive(:release_date)
            .and_return(
              installed_version_release_date,
              newest_version_release_date
            )
          allow(ruby).to receive(:installed_version)
          expect(ruby.libyears).to eq(1)
        end
      end

      describe '#name' do
        it 'returns "ruby"' do
          expect(described_class.new(nil).name).to eq('ruby')
        end
      end

      describe '#newest_version' do
        it 'returns the newest version' do
          newest_version = '2.4.2'
          ruby = described_class.new(nil)
          allow(ruby)
            .to receive(:all_versions)
            .and_return([{ 'version' => newest_version }])
          expect(ruby.newest_version).to eq(::Gem::Version.new(newest_version))
        end

        context 'newest version is a pre-release' do
          it 'returns the newest non-pre-release version' do
            older_version = '2.4.1'
            newest_version = '2.4.2'
            ruby = described_class.new(nil)
            allow(ruby)
              .to receive(:all_versions)
              .and_return([
                { 'version' => newest_version },
                { 'version' => older_version }
              ])
            expect(ruby.newest_version).to eq(::Gem::Version.new(newest_version))
          end
        end
      end

      describe '#newest_version_release_date' do
        it 'returns the release date for the newest version' do
          date = Date.new(2017, 1, 1)
          ruby = described_class.new(nil)
          allow(ruby)
            .to receive(:release_date)
            .and_return(date)
          allow(ruby).to receive(:installed_version)
          expect(ruby.newest_version_release_date).to eq(date)
        end
      end

      describe '#outdated?' do
        it 'returns true if installed version is less than newest version' do
          installed_version = ::Gem::Version.new('1.0.0')
          newest_version = ::Gem::Version.new('2.0.0')
          ruby = described_class.new(nil)
          allow(ruby).to receive(:installed_version).and_return(installed_version)
          allow(ruby).to receive(:newest_version).and_return(newest_version)
          expect(ruby.outdated?).to eq(true)
        end

        it 'returns false if installed version is equal to newest version' do
          installed_version = ::Gem::Version.new('1.0.0')
          newest_version = ::Gem::Version.new('1.0.0')
          ruby = described_class.new(nil)
          allow(ruby).to receive(:installed_version).and_return(installed_version)
          allow(ruby).to receive(:newest_version).and_return(newest_version)
          expect(ruby.outdated?).to eq(false)
        end
      end

      describe '#version_number_delta' do
        it 'returns the major, minor, and patch versions out-of-date' do
          installed_version = ::Gem::Version.new('1.0.0')
          newest_version = ::Gem::Version.new('2.0.0')
          ruby = described_class.new(nil)
          allow(ruby).to receive(:installed_version).and_return(installed_version)
          allow(ruby).to receive(:newest_version).and_return(newest_version)
          expect(ruby.version_number_delta).to eq([1, 0, 0])
        end
      end

      describe '#version_sequence_delta' do
        it 'returns the major, minor, and patch versions out-of-date' do
          ruby = described_class.new(nil)
          allow(ruby).to receive(:installed_version_sequence_index).and_return(1)
          allow(ruby).to receive(:newest_version_sequence_index).and_return(0)
          expect(ruby.version_sequence_delta).to eq(1)
        end
      end
    end
  end
end
