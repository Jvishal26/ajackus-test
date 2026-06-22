module Billetto
  class EventMapper
    def self.call(event)
      {
        billetto_id:         event["id"].to_s,
        title:               event["title"],
        description:         event["description"],
        image_url:           event["image_link"],
        url:                 event["url"],
        starts_at:           event["startdate"],
        ends_at:             event["enddate"],
        state:               event["state"],
        kind:                event["kind"],
        event_type:          event.dig("categorization", "type"),
        category:            event.dig("categorization", "category"),
        subcategory:         event.dig("categorization", "subcategory"),
        organizer_id:        event.dig("organiser", "id"),
        organizer_name:      event.dig("organiser", "name"),
        minimum_price_cents: event.dig("minimum_price", "amount_in_cents"),
        currency:            event.dig("minimum_price", "currency"),
        location_name:       event.dig("location", "location_name"),
        address:             "#{event.dig("location", "address_line")} #{event.dig("location", "address_line_2")}",
        city:                event.dig("location", "city"),
        postal_code:         event.dig("location", "postal_code"),
        country:             event.dig("location", "country"),
        latitude:            event.dig("location", "coordinates", "latitude"),
        longitude:           event.dig("location", "coordinates", "longitude")
      }
    end
  end
end
