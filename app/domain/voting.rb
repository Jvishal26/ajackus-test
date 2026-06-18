module Voting
  class EventUpvoted < Fact
    SCHEMA = {
      billetto_event_id: String,
      user_id: String,
    }.freeze

    def stream_names
      ["Voting$#{data.fetch(:billetto_event_id)}", "VotingByUser$#{data.fetch(:user_id)}"]
    end
  end

  class EventDownvoted < Fact
    SCHEMA = {
      billetto_event_id: String,
      user_id: String,
    }.freeze

    def stream_names
      ["Voting$#{data.fetch(:billetto_event_id)}", "VotingByUser$#{data.fetch(:user_id)}"]
    end
  end

  def self.subscriptions
    [
      ReadModels::VoteCounts,
    ].map(&:subscriptions).reduce(&:merge)
  end
end
