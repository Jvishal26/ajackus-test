require "rails_helper"

RSpec.describe "Authentication flow", type: :system do
  before do
    driven_by(:rack_test)
  end

  def sign_in_as(user_id)
    page.driver.submit :post, "/test/sign-in", { user_id: user_id }
  end

  it "shows sign in and sign up links to guests" do
    visit root_path
    expect(page).to have_link("Sign in")
    expect(page).to have_link("Sign up")
    expect(page).not_to have_content("Sign out")
  end

  it "sign in page is accessible" do
    visit sign_in_path
    expect(page).to have_content("Sign in")
  end

  it "sign up page is accessible" do
    visit sign_up_path
    expect(page).to have_content("Sign up")
  end

  it "shows sign out after signing in" do
    sign_in_as("user_abc")
    visit root_path
    expect(page).to have_content("Sign out")
    expect(page).not_to have_link("Sign in")
  end

  it "shows vote buttons when signed in" do
    create(:event, billetto_id: "evt1", title: "Copenhagen Jazz Festival")
    sign_in_as("user_abc")
    visit events_path
    expect(page).to have_content("Copenhagen Jazz Festival")
    expect(page).to have_button("Upvote")
    expect(page).to have_button("Downvote")
  end

  it "shows sign in to vote link when not signed in" do
    create(:event, billetto_id: "evt1", title: "Copenhagen Jazz Festival")
    visit events_path
    expect(page).to have_link("Sign in to vote")
    expect(page).not_to have_button("Upvote")
  end

  it "redirects to sign in when voting without auth" do
    page.driver.submit :post, votes_path(event_id: "evt_1", kind: "up"), {}
    expect(page).to have_current_path(sign_in_path)
  end
end
