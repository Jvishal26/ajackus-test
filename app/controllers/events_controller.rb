class EventsController < ApplicationController
  PER_PAGE = 20

  def index
    @page       = [params[:page].to_i, 1].max
    @total      = Event.count
    @total_pages = (@total / PER_PAGE.to_f).ceil
    @events     = Event.order(starts_at: :asc).limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
    @vote_counts = VoteCount.where(billetto_event_id: @events.map(&:billetto_id)).index_by(&:billetto_event_id)
  end
end
