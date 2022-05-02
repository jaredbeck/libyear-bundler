# frozen_string_literal: true

require 'spec_helper'

module LibyearBundler
  RSpec.describe ReleaseDateCache do
    describe '.load' do
      it 'has the expected size' do
        cache = described_class.load('spec/fixtures/02/cache.yml')
        expect(cache.size).to eq(2)
      end

      context 'when file does not exist' do
        it 'returns empty cache' do
          cache = described_class.load('/path/that/does/not/exist')
          expect(cache).to be_empty
        end
      end
    end
  end
end
