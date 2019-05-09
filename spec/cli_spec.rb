require 'spec_helper'

module LibyearBundler
  RSpec.describe CLI do
    %w[--all --releases --libyears --versions --grand-total].each do |flag|
      it "successfully runs with #{flag}" do
        expect { described_class.new([flag]).run }
          .not_to raise_error
      end
    end
  end
end
