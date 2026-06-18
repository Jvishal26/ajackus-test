require "net/http"
require "uri"
require "json"

module Billetto
  class EventsService
    def fetch_events(params = {})
      url = URI(AppSettings.billetto.events_endpoint)
      url.query = URI.encode_www_form(params) unless params.empty?
      response = build_http(url).request(build_request(url))
      JSON.parse(response.read_body) if response.is_a?(Net::HTTPSuccess)
    end

    def fetch_event(event_id)
      url = URI("#{AppSettings.billetto.events_endpoint}/#{event_id}")
      response = build_http(url).request(build_request(url))
      JSON.parse(response.read_body) if response.is_a?(Net::HTTPSuccess)
    end

    def fetch_public_events(params = { limit: AppSettings.billetto.pagination_limit })
      url = URI(AppSettings.billetto.public_events_endpoint)
      url.query = URI.encode_www_form(params) unless params.empty?

      loop do
        response = build_http(url).request(build_request(url))

        raise Billetto::ApiError, response.body unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.read_body)
        page_events = data["data"]

        mapped = page_events.map { |event| EventMapper.call(event) }.uniq { |e| e[:billetto_id] }
        Event.upsert_all(mapped, unique_by: :billetto_id) if mapped.any?

        break unless data["has_more"]
        break if data["next_url"].blank? || data["next_url"] == url.to_s

        url = URI(data["next_url"])
      end
    rescue Socket::ResolutionError,
           SocketError,
           Net::OpenTimeout,
           Net::ReadTimeout,
           Errno::ECONNREFUSED,
           Errno::ETIMEDOUT => e
      Rails.logger.error("Billetto request failed: #{e.class} - #{e.message}")
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
