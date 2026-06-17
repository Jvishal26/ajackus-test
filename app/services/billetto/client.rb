# app/services/billetto/client.rb

module Billetto
  class Client
    def events
      response = connection.get("/events")

      JSON.parse(response.body)
    end

    private

    def connection
      @connection ||= Faraday.new(
        url: ENV.fetch("BILLETTO_BASE_URL"),
        headers: {
          "Authorization" => "Bearer #{ENV.fetch('BILLETTO_API_KEY')}"
        }
      )
    end
  end
end