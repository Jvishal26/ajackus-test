Rails.configuration.to_prepare do
  event_store = RailsEventStore::Client.new
  Rails.configuration.event_store = event_store

  command_bus = CommandBus.new
  Rails.configuration.command_bus = command_bus

  ApplicationSubscriptions.new.handlers.each do |event_class, handler_class|
    event_store.subscribe(handler_class.new, to: [event_class])
  end
end
