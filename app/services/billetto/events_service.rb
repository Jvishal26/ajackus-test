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

    def fetch_public_events(params = {limit: AppSettings.billetto.pagination_limit})
      events = []
      url = URI(AppSettings.billetto.public_events_endpoint)

      loop do
        url.query ||= URI.encode_www_form(params) unless params.empty?

        begin 
          response = build_http(url).request(build_request(url))
        rescue Socket::ResolutionError,
                SocketError,
                Net::OpenTimeout,
                Net::ReadTimeout,
                Errno::ECONNREFUSED,
                Errno::ETIMEDOUT => e
          Rails.logger.error(
            "Billetto request failed: #{e.class} - #{e.message}"
          )
        end
        
        raise Billetto::ApiError, response.body unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.read_body)
        events.concat(data["data"])
        mapped = events.map { |event| EventMapper.call(event) }
                     .uniq { |e| e[:billetto_id] }
        Event.upsert_all(mapped, unique_by: :billetto_id)
        
        break unless data["has_more"]

        break if data["next_url"] == url.to_s

        url = URI(data["next_url"])
      end
      
      events
    end

    private

    def build_http(url)
      Net::HTTP.new(url.host, url.port).tap do |http|
        http.use_ssl = true
        http.open_timeout = 15
        http.read_timeout = 30
      end
    end

    def build_request(url)
      request = Net::HTTP::Get.new(url)
      request["accept"] = "application/json"
      request["Api-Keypair"] = api_keypair
      request
    end

    def api_keypair
      @api_keypair ||= "#{AppSettings.billetto.client_id}:#{AppSettings.billetto.client_secret}"
    end
  end
end
