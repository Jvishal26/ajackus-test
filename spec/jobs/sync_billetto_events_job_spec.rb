require 'rails_helper'

RSpec.describe SyncBillettoEventsJob, type: :job do
  describe "#perform" do
    let(:service) { instance_double(Billetto::EventsService) }

    before do
      allow(Billetto::EventsService).to receive(:new).and_return(service)
      allow(service).to receive(:fetch_public_events).and_return([])
    end

    it "calls fetch_public_events on the service" do
      described_class.new.perform
      expect(service).to have_received(:fetch_public_events)
    end

    it "passes after param when events exist" do
      create(:event, billetto_id: "last_event")
      described_class.new.perform
      expect(service).to have_received(:fetch_public_events).with({ after: "last_event" })
    end
  end
end
