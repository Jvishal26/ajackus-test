require 'rails_helper'

RSpec.describe Voting::UpvoteEvent do
  let(:event_store) { RailsEventStore::Client.new }
  let(:command_bus) { instance_double(CommandBus) }
  let(:billetto_event_id) { "evt_123" }
  let(:user_id) { "user_abc" }

  before do
    allow(Rails.configuration).to receive(:event_store).and_return(event_store)
    allow(Rails.configuration).to receive(:command_bus).and_return(command_bus)
  end

  subject(:command) do
    described_class.new(billetto_event_id: billetto_event_id, user_id: user_id)
  end

  it "is valid with required attributes" do
    expect(command).to be_valid
  end

  it "is invalid without billetto_event_id" do
    command.billetto_event_id = nil
    expect(command).not_to be_valid
  end

  it "is invalid without user_id" do
    command.user_id = nil
    expect(command).not_to be_valid
  end

  describe "#call" do
    it "publishes an EventUpvoted fact to the voting stream" do
      command.call

      events = event_store.read.stream("Voting$#{billetto_event_id}").to_a
      expect(events.length).to eq(1)
      expect(events.first).to be_a(Voting::EventUpvoted)
      expect(events.first.data[:user_id]).to eq(user_id)
    end

    it "links the event to the user stream" do
      command.call

      user_events = event_store.read.stream("VotingByUser$#{user_id}").to_a
      expect(user_events.length).to eq(1)
    end

    it "does not publish a second vote if user already voted" do
      command.call
      command.call

      events = event_store.read.stream("Voting$#{billetto_event_id}").to_a
      expect(events.length).to eq(1)
    end

    it "prevents voting after a downvote too" do
      Voting::DownvoteEvent.new(billetto_event_id: billetto_event_id, user_id: user_id).call
      command.call

      events = event_store.read.stream("Voting$#{billetto_event_id}").to_a
      expect(events.length).to eq(1)
      expect(events.first).to be_a(Voting::EventDownvoted)
    end
  end
end
