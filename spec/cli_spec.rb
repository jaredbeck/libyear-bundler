require 'spec_helper'

module LibyearBundler
  RSpec.describe CLI do
    describe "#run" do
      it 'outputs the libyear grand-total' do
        VCR.use_cassette("03-Gemfile-Rails") do
          message = "5.2\n"

          expect do
            described_class.new(["spec/fixtures/03/Gemfile", "--grand-total"]).run
          end.to output(message).to_stdout
        end
      end

      context "--ignore list is passed" do
        it "outputs a smaller libyear grand-total number because of the ignore" do
          VCR.use_cassette("03-Gemfile-Rails") do
            message = "0.4\n"

            expect do
              described_class.new(["spec/fixtures/03/Gemfile", "--grand-total", "--ignore",
                                   "actioncable,actionmailbox,actionmailer,actionpack,"\
                                   "actiontext,actionview,activejob,activemodel,"\
                                   "activerecord,activestorage,activesupport,"\
                                   "railties"]).run
            end.to output(message).to_stdout
          end
        end
      end
    end
  end
end
