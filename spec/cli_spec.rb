require 'spec_helper'

module LibyearBundler
  RSpec.describe CLI do
    describe "#run" do
      it 'outputs the libyear grand-total' do
        VCR.use_cassette("03-Gemfile-Rails") do
          message = "11.4\n"

          expect do
            described_class.new(["spec/fixtures/03/Gemfile", "--grand-total"]).run
          end.to output(message).to_stdout
        end
      end

      context "--ignore list is passed" do
        before do
          @ignored_gems = %w[actioncable actionmailbox actionmailer actionpack actiontext actionview activejob activemodel activerecord activestorage activesupport railties]
        end

        it "outputs a smaller libyear grand-total number because of the ignore" do
          VCR.use_cassette("03-Gemfile-Rails") do
            message = "5.4\n"

            expect do
              described_class.new(["spec/fixtures/03/Gemfile", "--grand-total", "--ignore",
                                   @ignored_gems.join(",")]).run
            end.to output(message).to_stdout
          end
        end

        it "doesn't include the filtered gems in the report" do
          VCR.use_cassette("03-Gemfile-Rails") do
            allow($stdout).to receive(:write)

            report = described_class.new(
              ["spec/fixtures/03/Gemfile", "--ignore",
              @ignored_gems.join(",")]
            ).run

            expect(report.to_h[:gems].map(&:name)).to_not include(*@ignored_gems)
          end
        end
      end
    end
  end
end
