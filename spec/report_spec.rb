# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

module LibyearBundler
  RSpec.describe Report do
    describe '#write' do
      it 'returns a tabular string with fixed-width columns' do
        # Instead of these stubs, I considered using VCR, but that would mean
        # committing a 7 MB cassette. Instead, I'd rather stub for now, and then
        # think about how to eager-load all the data before running the report.
        allow(Models::Gem).to(
          receive(:release_date)
            .with('rails', ::Gem::Version.new('7.1.2'))
            .and_return(::Date.new(2023, 11, 10))
        )
        allow(Models::Gem).to(
          receive(:release_date)
            .with('rails', ::Gem::Version.new('7.1.3'))
            .and_return(::Date.new(2024, 1, 16))
        )
        allow(Models::Ruby).to receive(:release_date)
        allow(Models::Ruby).to receive(:newest_version).and_return(::Gem::Version.new('3.3.0'))
        release_date_cache = nil
        gem = Models::Gem.new('rails', '7.1.2', '7.1.3', release_date_cache)
        lockfile = 'spec/fixtures/01/Gemfile.lock'
        ruby = Models::Ruby.new(lockfile, release_date_cache)
        opts = Options.new([]).parse
        io = StringIO.new
        report = described_class.new([gem], ruby, opts, io)
        report.write
        expect(io.string).to eq(
          <<-EOS
                         rails          7.1.2     2023-11-10          7.1.3     2024-01-16       0.2
                          ruby          2.4.2                         3.3.0                      0.0
System is 0.2 libyears behind
          EOS
        )
      end
    end
  end
end
