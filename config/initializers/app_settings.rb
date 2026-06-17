require "yaml"
require "erb"

raw_config = ERB.new(
  File.read(Rails.root.join("config/app_settings.yml"))
).result

config = YAML.safe_load(
  raw_config,
  aliases: true
)

def deep_options(obj)
  case obj
  when Hash
    ActiveSupport::InheritableOptions.new(
      obj.deep_symbolize_keys.transform_values { |v| deep_options(v) }
    )
  else
    obj
  end
end

AppSettings = deep_options(
  config.fetch(Rails.env)
)