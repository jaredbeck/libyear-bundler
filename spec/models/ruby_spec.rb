require 'spec_helper'

module LibyearBundler
  module Models
    RSpec.describe Ruby do
      before(:each) do
        described_class.instance_variable_set(:@_all_versions, nil)
      end

      describe '.all_versions' do
        it 'returns the expected array' do
          VCR.use_cassette("ruby_releases") do
            result = described_class.send(:all_versions)
            expect(result.length).to(be > 100)
          end
        end

        context 'when response code is 500' do
          it 'returns the empty array' do
            allow(::Net::HTTP).to receive(:start).and_return(
              double('mock response', code: 500, success?: false)
            )
            expect {
              expect(described_class.send(:all_versions)).to eq([])
            }.to(output("Unable to get Ruby version list: response code: 500\n").to_stderr)
            expect(::Net::HTTP).to have_received(:start)
          end
        end
      end

      describe '#installed_version' do
        it 'gets the version from bundler' do
          ruby_version = '2.4.2'
          ruby = described_class.new(nil, nil)
          allow(ruby).to receive(:version_from_bundler).and_return(ruby_version)
          expect(ruby.installed_version).to eq(ruby_version)
        end

        it 'gets the version from .ruby-version file' do
          ruby_version = '2.4.2'
          ruby = described_class.new(nil, nil)
          allow(ruby).to receive(:version_from_bundler).and_return(nil)
          allow(ruby).to receive(:version_from_ruby_version_file).and_return(ruby_version)
          expect(ruby.installed_version).to eq(ruby_version)
        end

        it 'gets the version from ruby' do
          ruby_version = '2.4.2'
          ruby = described_class.new(nil, nil)
          allow(ruby).to receive(:version_from_bundler).and_return(nil)
          allow(ruby).to receive(:version_from_ruby_version_file).and_return(nil)
          allow(ruby).to receive(:version_from_ruby).and_return(ruby_version)
          expect(ruby.installed_version).to eq(ruby_version)
        end
      end

      describe '.installed_version_release_date' do
        it 'returns the release date for the installed version' do
          date = Date.new(2017, 1, 1)
          ruby = described_class.new(nil, nil)
          allow(described_class)
            .to receive(:release_date)
            .and_return(date)
          allow(ruby).to receive(:installed_version).and_return('9.9.9')
          result = ruby.installed_version_release_date
          expect(described_class).to have_received(:release_date).with('9.9.9')
          expect(result).to eq(date)
        end
      end

      describe '#libyears' do
        it 'returns the number of years out-of-date' do
          installed_version_release_date = Date.new(2017, 1, 1)
          newest_version_release_date = Date.new(2018, 1, 1)
          ruby = described_class.new(nil, nil)
          allow(described_class)
            .to receive(:release_date)
            .and_return(
              installed_version_release_date,
              newest_version_release_date
            )
          allow(ruby).to receive(:installed_version).and_return('9.9.9')
          VCR.use_cassette("ruby_releases") do
            expect(ruby.libyears).to eq(1)
          end
          expect(described_class).to have_received(:release_date).twice
        end
      end

      describe '#name' do
        it 'returns "ruby"' do
          expect(described_class.new(nil, nil).name).to eq('ruby')
        end
      end

      describe '.newest_version' do
        it 'returns the newest version' do
          older_version = '2.4.1'
          newest_version = '2.4.2'
          allow(described_class)
            .to receive(:all_versions)
            .and_return([newest_version, older_version])
          result = described_class.newest_version
          expect(described_class).to have_received(:all_versions)
          expect(result).to eq(::Gem::Version.new(newest_version))
        end

        context 'newest version is a pre-release' do
          it 'returns the newest non-pre-release version' do
            newest_stable_version = '2.4.1'
            prerelease_version = '2.4.2dev'
            allow(described_class)
              .to receive(:all_versions)
              .and_return([prerelease_version, newest_stable_version])
            result = described_class.newest_version
            expect(described_class).to have_received(:all_versions)
            expect(result).to eq(::Gem::Version.new(newest_stable_version))
          end
        end
      end

      describe '#newest_version_release_date' do
        it 'returns the release date for the newest version' do
          date = Date.new(2017, 1, 1)
          allow(described_class).to receive(:newest_version).and_return('9.9.9')
          allow(described_class).to receive(:release_date).and_return(date)
          result = described_class.newest_version_release_date
          expect(described_class).to have_received(:newest_version)
          expect(described_class).to have_received(:release_date).with('9.9.9')
          expect(result).to eq(date)
        end
      end

      describe '#outdated?' do
        it 'returns true if installed version is less than newest version' do
          installed_version = ::Gem::Version.new('1.0.0')
          newest_version = ::Gem::Version.new('2.0.0')
          ruby = described_class.new(nil, nil)
          allow(ruby).to receive(:installed_version).and_return(installed_version)
          allow(ruby).to receive(:newest_version).and_return(newest_version)
          expect(ruby.outdated?).to eq(true)
        end

        it 'returns false if installed version is equal to newest version' do
          installed_version = ::Gem::Version.new('1.0.0')
          newest_version = ::Gem::Version.new('1.0.0')
          ruby = described_class.new(nil, nil)
          allow(ruby).to receive(:installed_version).and_return(installed_version)
          allow(ruby).to receive(:newest_version).and_return(newest_version)
          expect(ruby.outdated?).to eq(false)
        end
      end

      describe '#version_number_delta' do
        it 'returns the major, minor, and patch versions out-of-date' do
          installed_version = ::Gem::Version.new('1.0.0')
          newest_version = ::Gem::Version.new('2.0.0')
          ruby = described_class.new(nil, nil)
          allow(ruby).to receive(:installed_version).and_return(installed_version)
          allow(described_class).to receive(:newest_version).and_return(newest_version)
          result = ruby.version_number_delta
          expect(described_class).to have_received(:newest_version)
          expect(ruby).to have_received(:installed_version)
          expect(result).to eq([1, 0, 0])
        end
      end

      describe '#version_sequence_delta' do
        it 'returns the major, minor, and patch versions out-of-date' do
          ruby = described_class.new(nil, nil)
          allow(ruby).to receive(:installed_version_sequence_index).and_return(1)
          allow(described_class).to receive(:newest_version_sequence_index).and_return(0)
          expect(ruby.version_sequence_delta).to eq(1)
        end
      end
    end
  end
end
