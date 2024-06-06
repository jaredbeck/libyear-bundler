require 'spec_helper'

module LibyearBundler
  RSpec.describe Options do
    it 'sets libyears? to true by default' do
      opts = described_class.new([]).parse
      expect(opts.libyears?).to eq(true)
    end

    context '--all flag' do
      it 'sets all options to true' do
        opts = described_class.new(['--all']).parse
        [:libyears, :releases, :versions].each do |flag|
          expect(opts.send("#{flag}?".to_sym)).to eq(true)
        end
      end
    end

    context '--libyears flag' do
      it 'sets libyears? to true' do
        opts = described_class.new(['--libyears']).parse
        expect(opts.libyears?).to eq(true)
      end
    end

    context '--releases flag' do
      it 'sets libyears? to true' do
        opts = described_class.new(['--releases']).parse
        expect(opts.libyears?).to eq(false)
        expect(opts.releases?).to eq(true)
      end
    end

    context '--versions flag' do
      it 'sets libyears? to true' do
        opts = described_class.new(['--versions']).parse
        expect(opts.libyears?).to eq(false)
        expect(opts.versions?).to eq(true)
      end
    end

    context '--sort flag' do
      it 'sets sort? to true' do
        opts = described_class.new(['--sort']).parse
        expect(opts.sort?).to eq(true)
      end
    end

    context 'invalid option' do
      it 'prints the help' do
        opts = described_class.new(['--black-flag'])
        expect { opts.parse }
          .to raise_error(::SystemExit)
          .and(output.to_stderr)
      end
    end

    context 'with Gemfile path' do
      it 'sets libyears? to true by default' do
        opts = described_class.new(['/path/to/Gemfile']).parse
        expect(opts.libyears?).to eq(true)
      end
    end
  end
end
