module Voting
  module ReadModels
    class VoteCounts
      def self.subscriptions
        {
          Voting::EventUpvoted => self,
          Voting::EventDownvoted => self,
        }
      end

      def call(event)
        billetto_event_id = event.data.fetch(:billetto_event_id)

        ApplicationRecord.transaction do
          record = VoteCount.find_or_initialize_by(billetto_event_id: billetto_event_id)
          record.lock! unless record.new_record?

          case event
          when Voting::EventUpvoted
            record.upvotes += 1
          when Voting::EventDownvoted
            record.downvotes += 1
          end

          record.save!
        end
      end
    end
  end
end
