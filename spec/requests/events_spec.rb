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
  def stub_clerk_proxy(user_id: nil)
    proxy = instance_double(Clerk::Proxy, user?: user_id.present?, user_id: user_id, user: nil)
    allow_any_instance_of(ApplicationController).to receive(:clerk_proxy).and_return(proxy)
  end

  describe "POST /votes" do
    context "when user is not authenticated" do
      before { stub_clerk_proxy }

      it "redirects to sign-in" do
        post votes_path(event_id: "evt_1", kind: "up")
        expect(response).to redirect_to(sign_in_path)
      end
    end

    context "when user is authenticated" do
      let(:user_id) { "clerk_user_123" }

      before do
        stub_clerk_proxy(user_id: user_id)
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

RSpec.describe "Sessions", type: :request do
  def stub_clerk_proxy(user_id: nil)
    proxy = instance_double(Clerk::Proxy, user?: user_id.present?, user_id: user_id, user: nil)
    allow_any_instance_of(ApplicationController).to receive(:clerk_proxy).and_return(proxy)
  end

  describe "GET /sign-in" do
    it "renders the sign-in page when not authenticated" do
      stub_clerk_proxy
      get sign_in_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to root when already signed in" do
      stub_clerk_proxy(user_id: "user_abc")
      get sign_in_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /sign-up" do
    it "renders the sign-up page when not authenticated" do
      stub_clerk_proxy
      get sign_up_path
      expect(response).to have_http_status(:success)
    end

    it "redirects to root when already signed in" do
      stub_clerk_proxy(user_id: "user_abc")
      get sign_up_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELETE /sign-out" do
    it "redirects after sign-out" do
      stub_clerk_proxy(user_id: "user_abc")
      delete sign_out_path
      expect(response).to have_http_status(:redirect)
    end
  end
end
