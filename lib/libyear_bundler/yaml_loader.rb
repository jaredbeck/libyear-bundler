# frozen_string_literal: true

require 'yaml'

module LibyearBundler
  # Supports different versions of the `YAML` constant. For example,
  #
  # > psych 3.0.3 YAML#safe_load expected the permitted/whitelisted classes in
  # > the second parameter.
  # >
  # > psych 3.1.0 YAML#safe_load introduced keyword argument permitted_classes
  # > in addition to permitted/whitelisted classes in the second parameter.
  # >
  # > psych 4.0.0 dropped the second positional parameter of YAML#safe_load, and
  # > expects the permitted/whitelisted classes only in keyword parameter
  # > permitted_classes.
  # > https://github.com/jaredbeck/libyear-bundler/issues/22
  #
  # I expect this will only get more complicated over the years, as we try to
  # support old rubies for as long as possible.
  #
  # Other known issues:
  #
  # - https://github.com/ruby/psych/issues/262
  module YAMLLoader
    class << self
      def safe_load(yaml, permitted_classes: [::Date])
        if YAML.method(:safe_load).parameters.include?([:key, :permitted_classes])
          YAML.safe_load(yaml, permitted_classes: permitted_classes)
        else
          YAML.safe_load(yaml, permitted_classes)
        end
      end
    end
  end
end
