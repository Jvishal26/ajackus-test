require 'rails_helper'

RSpec.describe "Events", type: :request do
  describe "GET /events" do
    it "returns http success" do
      get events_path
      expect(response).to have_http_status(:success)
    end

    it "shows events" do
      create(:event, billetto_id: "show1", title: "Tech Meetup Copenhagen")
      get events_path
      expect(response.body).to include("Tech Meetup Copenhagen")
    end
  end
end

RSpec.describe "Votes", type: :request do
  describe "POST /votes" do
    context "when user is not authenticated" do
      before { allow_any_instance_of(ApplicationController).to receive(:current_user_id).and_return(nil) }

      it "redirects to root with alert" do
        post votes_path(event_id: "evt_1", kind: "up")
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is authenticated" do
      let(:user_id) { "clerk_user_123" }

      before do
        allow_any_instance_of(ApplicationController).to receive(:current_user_id).and_return(user_id)
        allow(Rails.configuration).to receive(:command_bus).and_return(
          instance_double(CommandBus, call: nil)
        )
      end

      it "accepts upvote and redirects" do
        post votes_path(event_id: "evt_1", kind: "up")
        expect(response).to redirect_to(events_path)
      end

      it "accepts downvote and redirects" do
        post votes_path(event_id: "evt_1", kind: "down")
        expect(response).to redirect_to(events_path)
      end
    end
  end
end
