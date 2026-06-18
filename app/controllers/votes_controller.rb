class VotesController < ApplicationController
  def create
    command_class = params[:kind] == "down" ? Voting::DownvoteEvent : Voting::UpvoteEvent

    command = command_class.new(
      billetto_event_id: params[:event_id],
      user_id: session_user_id
    )

    Rails.configuration.command_bus.call(command)

    redirect_to events_path, notice: "Vote recorded!"
  rescue ActiveModel::ValidationError => e
    redirect_to events_path, alert: e.message
  rescue => e
    Rails.logger.error("Vote failed: #{e.message}")
    redirect_to events_path, alert: "Something went wrong, please try again"
  end

  private

  def session_user_id
    session[:user_id] ||= SecureRandom.uuid
  end
end
