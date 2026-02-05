require 'spec_helper'

module LibyearBundler
  module Models
    RSpec.describe Gem do
      describe '.release_date' do
        context 'with rubygems.org source' do
          it 'queries rubygems.org API' do
            http = instance_double(Net::HTTP)
            response = instance_double(Net::HTTPSuccess)
            allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
            allow(response).to receive(:body)
              .and_return('{"version_created_at":"2017-01-01T00:00:00Z"}')
            allow(http).to receive(:request).and_return(response)

            result = described_class.release_date('json', '2.1.0', http, 'https://rubygems.org/')

            expect(result).to eq(Date.parse('2017-01-01'))
          end
        end

        context 'with GitHub Packages source' do
          context 'when gh CLI is available' do
            it 'queries GitHub API via gh CLI' do
              http = instance_double(Net::HTTP)
              allow(described_class).to receive(:gh_available?).and_return(true)
              allow(described_class).to receive(:gh_api_call)
                .with('/orgs/secret_org/packages/rubygems/private_gem1/versions')
                .and_return(['[{"name":"2.6.0","created_at":"2025-11-18T22:27:39Z"}]', true])

              result = described_class.release_date(
                'private_gem1',
                '2.6.0',
                http,
                'https://rubygems.pkg.github.com/secret_org/'
              )

              expect(result).to eq(Date.parse('2025-11-18'))
            end
          end

          context 'when gh CLI is not available' do
            it 'returns nil and does not query' do
              http = instance_double(Net::HTTP)
              allow(described_class).to receive(:gh_available?).and_return(false)
              allow(described_class).to receive(:report_problem)

              result = described_class.release_date(
                'private_gem1',
                '2.6.0',
                http,
                'https://rubygems.pkg.github.com/secret_org/'
              )

              expect(result).to be_nil
              expect(described_class).to have_received(:report_problem)
                .with('private_gem1', /skipped.*private source/i)
            end
          end
        end

        context 'with unknown source' do
          it 'returns nil and reports skipped' do
            http = instance_double(Net::HTTP)
            allow(described_class).to receive(:report_problem)

            result = described_class.release_date(
              'private_gem',
              '1.0.0',
              http,
              'https://custom.gem.server/'
            )

            expect(result).to be_nil
            expect(described_class).to have_received(:report_problem)
              .with('private_gem', /skipped.*unsupported source/i)
          end
        end
      end

      describe '.gh_available?' do
        it 'returns true when gh command exists' do
          allow(described_class).to receive(:system)
            .with('which gh > /dev/null 2>&1')
            .and_return(true)

          expect(described_class.gh_available?).to be true
        end

        it 'returns false when gh command does not exist' do
          allow(described_class).to receive(:system)
            .with('which gh > /dev/null 2>&1')
            .and_return(false)

          expect(described_class.gh_available?).to be false
        end
      end
    end
  end
end
