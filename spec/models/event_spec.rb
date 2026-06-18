require 'rails_helper'

RSpec.describe Event, type: :model do
  subject(:event) { build(:event) }

  it "is valid with required attributes" do
    expect(event).to be_valid
  end

  describe "validations" do
    it "requires title" do
      event.title = nil
      expect(event).not_to be_valid
      expect(event.errors[:title]).to include("can't be blank")
    end

    it "requires billetto_id" do
      event.billetto_id = nil
      expect(event).not_to be_valid
    end

    it "requires starts_at" do
      event.starts_at = nil
      expect(event).not_to be_valid
    end

    it "enforces billetto_id uniqueness" do
      create(:event, billetto_id: "abc123")
      duplicate = build(:event, billetto_id: "abc123")
      expect(duplicate).not_to be_valid
    end

    it "validates ends_at is after starts_at when both present" do
      event.starts_at = 1.day.from_now
      event.ends_at = 1.hour.from_now
      expect(event).not_to be_valid
      expect(event.errors[:ends_at]).to include("must be after start time")
    end

    it "allows ends_at to be nil" do
      event.ends_at = nil
      expect(event).to be_valid
    end
  end

  describe ".upcoming" do
    it "returns events starting in the future ordered by start time" do
      create(:event, billetto_id: "past1", starts_at: 2.days.ago)
      soon  = create(:event, billetto_id: "soon1", starts_at: 1.day.from_now)
      later = create(:event, billetto_id: "later1", starts_at: 3.days.from_now)

      expect(Event.upcoming).to eq([soon, later])
    end
  end
end
