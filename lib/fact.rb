class Fact < RubyEventStore::Event
  def self.strict(data:, **kwargs)
    validate_schema!(data) if const_defined?(:SCHEMA)
    new(data: data, **kwargs)
  end

  def stream_names
    raise NotImplementedError, "#{self.class} must implement #stream_names"
  end

  private_class_method def self.validate_schema!(data)
    const_get(:SCHEMA).each_key do |key|
      raise ArgumentError, "Missing required field: #{key}" unless data.key?(key)
    end
  end
end
