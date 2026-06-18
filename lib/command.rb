module Command
  module Executable
    def self.included(base)
      base.include ActiveModel::Model
      base.extend AttributeMethods
    end

    module AttributeMethods
      def attribute(name, _type = nil, **_opts)
        attr_accessor name
      end
    end

    def call
      raise NotImplementedError, "#{self.class}#call not implemented"
    end

    private

    def event_store
      Rails.configuration.event_store
    end

    def command_bus
      Rails.configuration.command_bus
    end
  end

  module Handler
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def handles(command_class, method_name)
        command_registry[command_class] = method_name
      end

      def command_registry
        @command_registry ||= {}
      end

      def subscriptions
        command_registry.keys.each_with_object({}) do |cmd, hash|
          hash[cmd] = self
        end
      end
    end

    def call(command)
      method_name = self.class.command_registry[command.class]
      raise "No handler registered for #{command.class}" unless method_name
      send(method_name, command)
    end

    private

    def event_store
      Rails.configuration.event_store
    end

    def command_bus
      Rails.configuration.command_bus
    end
  end
end
