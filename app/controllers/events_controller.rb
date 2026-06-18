class EventsController < ApplicationController
  def index
    return unless user_signed_in?

    @events = Event.order(starts_at: :asc).limit(50)
    @vote_counts = VoteCount.where(billetto_event_id: @events.map(&:billetto_id)).index_by(&:billetto_event_id)
  end
end
