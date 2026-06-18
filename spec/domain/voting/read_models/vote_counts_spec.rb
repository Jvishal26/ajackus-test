require 'rails_helper'

RSpec.describe Voting::ReadModels::VoteCounts do
  subject(:handler) { described_class.new }

  let(:billetto_event_id) { "evt_789" }

  describe "#call" do
    context "when an EventUpvoted is received" do
      let(:event) do
        Voting::EventUpvoted.strict(
          data: { billetto_event_id: billetto_event_id, user_id: "user_1" }
        )
      end

      it "increments upvotes" do
        handler.call(event)
        record = VoteCount.find_by!(billetto_event_id: billetto_event_id)
        expect(record.upvotes).to eq(1)
        expect(record.downvotes).to eq(0)
      end

      it "increments upvotes on subsequent calls" do
        handler.call(event)
        handler.call(
          Voting::EventUpvoted.strict(data: { billetto_event_id: billetto_event_id, user_id: "user_2" })
        )
        expect(VoteCount.find_by!(billetto_event_id: billetto_event_id).upvotes).to eq(2)
      end
    end

    context "when an EventDownvoted is received" do
      let(:event) do
        Voting::EventDownvoted.strict(
          data: { billetto_event_id: billetto_event_id, user_id: "user_3" }
        )
      end

      it "increments downvotes" do
        handler.call(event)
        record = VoteCount.find_by!(billetto_event_id: billetto_event_id)
        expect(record.downvotes).to eq(1)
        expect(record.upvotes).to eq(0)
      end
    end
  end

  describe ".subscriptions" do
    it "subscribes to EventUpvoted and EventDownvoted" do
      subs = described_class.subscriptions
      expect(subs.keys).to contain_exactly(Voting::EventUpvoted, Voting::EventDownvoted)
    end
  end
end
