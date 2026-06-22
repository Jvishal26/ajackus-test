require "rails_helper"

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

    it "shows sign in link when not authenticated" do
      get events_path
      expect(response.body).to include("Sign in")
    end

    it "shows vote buttons when authenticated" do
      create(:event, billetto_id: "evt1", title: "Some Event")
      sign_in_as("user_abc")
      get events_path
      expect(response.body).to include("Upvote")
      expect(response.body).to include("Downvote")
    end

    it "paginates at 20 per page" do
      21.times { create(:event) }
      get events_path(page: 1)
      expect(response.body).to include("Next")
    end

    it "shows the second page" do
      21.times { create(:event) }
      get events_path(page: 2)
      expect(response).to have_http_status(:success)
    end
  end
end

RSpec.describe "Votes", type: :request do
  describe "POST /votes" do
    context "when not authenticated" do
      it "redirects to sign in" do
        post votes_path(event_id: "evt_1", kind: "up")
        expect(response).to redirect_to(sign_in_path)
      end
    end

    context "when authenticated" do
      before do
        sign_in_as("user_123")
        allow(Rails.configuration).to receive(:command_bus).and_return(
          instance_double(CommandBus, call: nil)
        )
      end

      it "accepts an upvote and redirects to events" do
        post votes_path(event_id: "evt_1", kind: "up")
        expect(response).to redirect_to(events_path)
      end

      it "accepts a downvote and redirects to events" do
        post votes_path(event_id: "evt_1", kind: "down")
        expect(response).to redirect_to(events_path)
      end
    end
  end
end
