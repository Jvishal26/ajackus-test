class SyncBillettoEventsJob < ApplicationJob
  queue_as :default

  def perform
    Billetto::EventsService.new.fetch_public_events
  end
end
