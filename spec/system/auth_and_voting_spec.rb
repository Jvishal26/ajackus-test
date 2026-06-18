require "rails_helper"

RSpec.describe "Authentication flow", type: :system do
  describe "landing page" do
    it "shows sign-in and sign-up links when not logged in" do
      visit root_path

      expect(page).to have_link("Sign in",  href: sign_in_path)
      expect(page).to have_link("Sign up",  href: sign_up_path)
      expect(page).not_to have_button("Sign out")
    end

    it "does not show event listing to unauthenticated visitors" do
      create(:event, title: "Secret Event")
      visit root_path

      expect(page).not_to have_content("Secret Event")
    end
  end

  describe "sign-in page" do
    it "renders the Clerk sign-in component container" do
      visit sign_in_path

      expect(page).to have_css("#clerk-sign-in")
      expect(page.status_code).to eq(200)
    end

    it "redirects to root if already signed in" do
      sign_in_as("user_abc")
      visit sign_in_path

      expect(page).to have_current_path(root_path)
    end
  end

  describe "sign-up page" do
    it "renders the Clerk sign-up component container" do
      visit sign_up_path

      expect(page).to have_css("#clerk-sign-up")
      expect(page.status_code).to eq(200)
    end

    it "redirects to root if already signed in" do
      sign_in_as("user_abc")
      visit sign_up_path

      expect(page).to have_current_path(root_path)
    end
  end

  describe "authenticated session" do
    before { sign_in_as("user_test_001") }

    it "shows the events listing after sign-in" do
      create(:event, title: "Copenhagen Jazz Festival")
      visit root_path

      expect(page).to have_content("Copenhagen Jazz Festival")
      expect(page).not_to have_link("Sign in")
      expect(page).not_to have_link("Sign up")
    end

    it "shows the sign-out button in the nav" do
      visit root_path
      expect(page).to have_button("Sign out")
    end

    it "clears the session on sign-out" do
      visit root_path
      click_button "Sign out"

      sign_out_test_session
      visit root_path

      expect(page).to have_link("Sign in")
    end
  end

  describe "voting restrictions" do
    let!(:event) { create(:event, title: "Tech Talks Berlin") }

    context "when not signed in" do
      it "redirects vote attempts to sign-in" do
        page.driver.post(votes_path, event_id: event.billetto_id, kind: "up")
        expect(page.driver.response.headers["Location"]).to include(sign_in_path)
      end
    end

    context "when signed in" do
      before { sign_in_as("voter_001") }

      it "shows vote buttons on event cards" do
        visit root_path
        expect(page).to have_button("👍")
        expect(page).to have_button("👎")
      end

      it "records an upvote and updates the count" do
        visit root_path
        expect(page).to have_content("👍 0")

        click_button "👍", match: :first
        visit root_path

        expect(page).to have_content("👍 1")
      end

      it "records a downvote and updates the count" do
        visit root_path
        click_button "👎", match: :first
        visit root_path

        expect(page).to have_content("👎 1")
      end

      it "does not record a second vote from the same user" do
        visit root_path
        click_button "👍", match: :first
        visit root_path
        click_button "👍", match: :first
        visit root_path

        expect(page).to have_content("👍 1")
      end
    end
  end
end
