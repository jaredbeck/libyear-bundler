require 'spec_helper'

module LibyearBundler
  RSpec.describe BundleOutdated do
    context 'dependency installed from git' do
      it 'skips the dependency' do
        bundle_outdated = described_class.new('', nil)
        line = "gem_installed_from_git (newest 3.0.0.pre 73d9477, installed 3.0.0.pre 251fb80)"
        allow(bundle_outdated).to receive(:bundle_outdated).and_return(line)
        result = nil
        expect {
          result = bundle_outdated.execute
        }.to output(
          "Skipping gem_installed_from_git because of a malformed version string\n"
        ).to_stderr
        expect(result).to eq([])
      end
    end
  end
end
