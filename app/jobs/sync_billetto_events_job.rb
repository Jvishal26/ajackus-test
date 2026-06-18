class SyncBillettoEventsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Billetto::EventsService.new.fetch_public_events({after: Event&.last&.billetto_id})
  end
end
