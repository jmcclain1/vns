class String

  def self.add_customized_message(standard_message, customized_message)
#    p customized_messages[standard_message]
    customized_messages[standard_message] = customized_message
#    p customized_messages[standard_message]
  end

  def self.customized_messages
    @@CUSTOMIZED_MESSAGES
  end

  def customize(substitutions = {})
    customized_message = String.customized_messages[self]
    return self unless customized_message
    return customized_message if substitutions.empty?
    substitute(customized_message, substitutions)
  end

  def substitute(customized_message, substitutions)
    result = customized_message.dup
    substitutions.each do |key, value|
      parameter = "{:#{key}}"
      result.gsub!(parameter, value)
    end
    result
  end

  def self.load_customized_messages_from_config
    filename = "#{RAILS_ROOT}/config/customized_messages.yml"
    if File.exist? filename
      File.open(filename) do |file|
        @@CUSTOMIZED_MESSAGES = from_yaml(file.read)
      end
    else
      @@CUSTOMIZED_MESSAGES = {}
    end
  end

  def self.from_yaml(yaml_string)
    erb_parsed_yaml = ERB.new(yaml_string).result
    YAML.load(erb_parsed_yaml)
  end

  load_customized_messages_from_config
end


