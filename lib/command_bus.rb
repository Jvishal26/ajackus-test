class CommandBus
  def initialize
    @handlers = {}
  end

  def register(command_class, handler)
    @handlers[command_class] = handler
    self
  end

  def call(command)
    validate!(command)

    ActiveRecord::Base.transaction do
      if command.class.ancestors.include?(Command::Executable)
        command.call
      else
        handler = find_handler!(command)
        handler.call(command)
      end
    end
  end

  private

  def validate!(command)
    return unless command.respond_to?(:valid?)
    raise ActiveModel::ValidationError.new(command) unless command.valid?
  end

  def find_handler!(command)
    handler_class = @handlers[command.class]
    raise "No handler registered for #{command.class}" unless handler_class
    handler_class.new
  end
end
