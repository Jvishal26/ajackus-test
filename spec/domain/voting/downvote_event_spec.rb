require 'rails_helper'

RSpec.describe Voting::DownvoteEvent do
  let(:event_store) { RailsEventStore::Client.new }
  let(:billetto_event_id) { "evt_456" }
  let(:user_id) { "user_xyz" }

  before do
    allow(Rails.configuration).to receive(:event_store).and_return(event_store)
    allow(Rails.configuration).to receive(:command_bus).and_return(instance_double(CommandBus))
  end

  subject(:command) do
    described_class.new(billetto_event_id: billetto_event_id, user_id: user_id)
  end

  describe "#call" do
    it "publishes an EventDownvoted fact" do
      command.call

      events = event_store.read.stream("Voting$#{billetto_event_id}").to_a
      expect(events.length).to eq(1)
      expect(events.first).to be_a(Voting::EventDownvoted)
    end

    it "does not allow voting twice" do
      command.call
      command.call

      events = event_store.read.stream("Voting$#{billetto_event_id}").to_a
      expect(events.length).to eq(1)
    end
  end
end
