# app/services/billetto/events_service.rb
require "net/http"
require "uri"
require "json"

module Billetto
  class EventsService
    def fetch_events(params = {})
      url = URI(AppSettings.billetto.events_endpoint)
      url.query = URI.encode_www_form(params) unless params.empty?
      http = build_http(url)
      request = build_request(url)

      response = http.request(request)
      JSON.parse(response.read_body) if response.is_a?(Net::HTTPSuccess)
    end

    def fetch_event(event_id)
      url = URI("#{AppSettings.billetto.events_endpoint}/#{event_id}")
      http = build_http(url)
      request = build_request(url)

      response = http.request(request)
      JSON.parse(response.read_body) if response.is_a?(Net::HTTPSuccess)
    end

    private

    def build_http(url)
      @http ||= Net::HTTP.new(url.host, url.port).tap do |http|
        http.use_ssl = true
        http.open_timeout = 5
        http.read_timeout = 10
      end
    end

    def build_request(url)
      request = Net::HTTP::Get.new(url)
      request["accept"] = 'application/json'
      request["Api-Keypair"] = api_keypair
      request
    end

    def api_keypair
      @api_keypair ||= "#{AppSettings.billetto.client_id}:#{AppSettings.billetto.client_secret}"
    end
  end
end