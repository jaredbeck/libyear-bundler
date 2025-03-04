# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

module LibyearBundler
  module Reports
    RSpec.describe Console do
      describe '#write' do
        it 'returns a tabular string with fixed-width columns' do
          ruby = stub_ruby
          gems = [stub_pg_gem, stub_rails_gem]
          opts = Options.new([]).parse
          io = StringIO.new
          report = described_class.new(gems, ruby, opts, io)
          report.write
          expect(io.string).to eq(
            <<-EOS
                            pg          1.5.0     2023-04-24          1.5.6     2024-03-01       0.9
                         rails          7.0.0     2021-12-15          7.1.3     2024-01-16       2.1
                          ruby          2.4.2                         3.3.0                      0.0
System is 2.9 libyears behind
            EOS
          )
        end

        it 'sorts by selected metric' do
          ruby = stub_ruby
          gems = [stub_pg_gem, stub_rails_gem]
          opts = Options.new(['--sort']).parse
          io = StringIO.new
          report = described_class.new(gems, ruby, opts, io)
          report.write
          expect(io.string).to eq(
            <<-EOS
                         rails          7.0.0     2021-12-15          7.1.3     2024-01-16       2.1
                            pg          1.5.0     2023-04-24          1.5.6     2024-03-01       0.9
                          ruby          2.4.2                         3.3.0                      0.0
System is 2.9 libyears behind
            EOS
          )
        end
      end

      private

      # Instead of these stubs, I considered using VCR, but that would mean
      # committing a 7 MB cassette. Instead, I'd rather stub for now, and then
      # think about how to eager-load all the data before running the report.
      def stub_ruby
        allow(Models::Ruby).to receive(:release_date)
        allow(Models::Ruby).to receive(:newest_version).and_return(::Gem::Version.new('3.3.0'))
        lockfile = 'spec/fixtures/01/Gemfile.lock'
        Models::Ruby.new(lockfile, nil)
      end

      def stub_pg_gem
        allow(Models::Gem).to(
          receive(:release_date)
            .with('pg', ::Gem::Version.new('1.5.0'))
            .and_return(::Date.new(2023, 4, 24))
        )
        allow(Models::Gem).to(
          receive(:release_date)
            .with('pg', ::Gem::Version.new('1.5.6'))
            .and_return(::Date.new(2024, 3, 1))
        )

        Models::Gem.new('pg', '1.5.0', '1.5.6', nil)
      end

      def stub_rails_gem
        allow(Models::Gem).to(
          receive(:release_date)
            .with('rails', ::Gem::Version.new('7.0.0'))
            .and_return(::Date.new(2021, 12, 15))
        )
        allow(Models::Gem).to(
          receive(:release_date)
            .with('rails', ::Gem::Version.new('7.1.3'))
            .and_return(::Date.new(2024, 1, 16))
        )

        Models::Gem.new('rails', '7.0.0', '7.1.3', nil)
      end
    end
  end
end
