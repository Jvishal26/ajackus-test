FactoryBot.define do
  factory :event do
    sequence(:billetto_id) { |n| "evt_#{n}" }
    title { Faker::Music::RockBand.name + " Live" }
    description { Faker::Lorem.paragraph }
    image_url { "https://example.com/image.jpg" }
    starts_at { 1.week.from_now }
    ends_at { 1.week.from_now + 2.hours }
    city { "Copenhagen" }
    country { "DK" }
  end
end
