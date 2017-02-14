require "bundler/cli"
require "bundler/cli/outdated"
require "libyear/report"
require "libyear/query"

module Libyear
  class CLI
    def initialize(argv)
      validate_arguments(argv)
      @gemfile_path = argv.first
    end

    def run
      print Report.new(Query.new(@gemfile_path).execute).to_s
    end

    private

    def validate_arguments(argv)
      # todo
    end
  end
end
