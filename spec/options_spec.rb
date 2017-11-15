require 'spec_helper'

module LibyearBundler
  RSpec.describe Options do
    it 'sets instance vars' do
      opts = described_class.new([])
      expect(opts.instance_variable_get(:@argv)).to eq([])
      expect(opts.instance_variable_get(:@options)).to eq({})
      expect(opts.instance_variable_get(:@optparser)).to be_a(::OptionParser)
    end

    context 'invalid option' do
      it 'prints the help' do
        opts = described_class.new(['--black-flag'])
        optparser = opts.instance_variable_get(:@optparser)
        expect { opts.parse! }
          .to raise_error(::SystemExit)
          .and(output.to_stderr)
      end
    end
  end
end
