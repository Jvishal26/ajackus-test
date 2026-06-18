module Voting
  class DownvoteEvent
    include Command::Executable

    attribute :billetto_event_id, String
    attribute :user_id, String

    validates :billetto_event_id, :user_id, presence: true

    def call
      return if already_voted?

      fact = Voting::EventDownvoted.strict(
        data: { billetto_event_id: billetto_event_id, user_id: user_id }
      )

      event_store.publish(fact, stream_name: fact.stream_names.first)
      fact.stream_names[1..].each do |stream|
        event_store.link(fact.event_id, stream_name: stream)
      end
    end

    private

    def already_voted?
      event_store.read
        .stream("Voting$#{billetto_event_id}")
        .of_type([Voting::EventUpvoted, Voting::EventDownvoted])
        .to_a
        .any? { |e| e.data[:user_id] == user_id }
    end
  end
end
