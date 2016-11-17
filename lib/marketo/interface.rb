# An interface to a few endpoint of the Marketo REST API.
# http://developers.marketo.com/rest-api/endpoint-reference/lead-database-endpoint-reference/

require 'faraday'
require 'json'

module Marketo
  class Interface
    def initialize(client, identity_service)
      @client = client
      @identity_service = identity_service
    end

    def send_request(method, endpoint, params: {}, body: nil)
      check_authorization!

      response = @client.send(method) do |req|
        req.url endpoint
        req.headers['Content-Type'] = 'application/json'
        req.body = body.to_json
        req.params.merge! params
      end

      handle_failure! response
    end

    def check_authorization!
      unless @identity_service.authenticated?
        access_token = @identity_service.authenticate!
        @client.authorization(:Bearer, access_token)
      end
    end

    def handle_failure!(response)
      response_body = JSON.parse(response.body)

      if response.status != 200
        raise ApiError.from_status(response.status, response.reason_phrase)
      elsif response_body["success"] == false
        raise ApiError.from_errors(response_body["errors"])
      else
        response_body["result"]
      end
    end

    # Gets a lead from Marketo using a Marketo ID.
    #
    # @param Id [Fixnum] The Marketo ID of the lead to fetch.
    # @return [Hash, nil] The lead's attributes, or nil if the lead is not found.
    # @note It is possible that this can return more than one lead - this only returns the first.
    # @raise [ArgumentError] if no ID is provided
    # @raise [Marketo::ApiError] if Marketo returns an error
    def get_lead_by_id(id)
      raise ArgumentError, "ID must be provided" if id.nil?
      endpoint = "/rest/v1/leads/#{id}.json"

      results = send_request(:get, endpoint)

      results.first
    end

    # Gets a lead from Marketo using their email.
    #
    # @param email [String] The Marketo ID of the lead to fetch.
    # @note It is possible that this can return more than one lead - this only returns the first.
    # @return [Hash, nil] The lead's attributes, or nil if the lead is not found.
    # @raise [ArgumentError] if no email is provided
    # @raise [Marketo::ApiError] if Marketo returns an error
    def get_lead_by_email(email)
      raise ArgumentError, "Email must be provided" if email.nil?

      endpoint = "/rest/v1/leads.json"
      params = {
        filterType: "email",
        filterValues: email
      }

      results = send_request(:get, endpoint, params: params)

      results.first
    end

    # Syncs one lead to marketo, optionally with a cookie.
    #
    # @param attributes [Hash] The attributes of the leadto be synced.
    # @param program [String] The program to associate the leads with.
    # @param cookie [String] The munchkin cookie to assign to the user.
    # @note This uses the `push` endpoint, which requires a program to generate an event.
    # @return [Array<Hash>] The result of the sync, which usually has "id", "status" and "error" fields for each record.
    # @raise [ArgumentError] if no email is provided
    # @raise [Marketo::ApiError] if Marketo returns an error
    def sync_lead(attributes, program, cookie = nil)
      raise ArgumentError, "No attributes to sync" if attributes.nil? || attributes.empty?
      raise ArgumentError, "Program is required" if program.nil?

      endpoint = "/rest/v1/leads/push.json"

      if(cookie.nil? || (cookie.include?("token:") == false))
        _cookie = nil
      else
        _cookie = cookie.slice!(cookie.index("token:")..-1)
      end

      _attributes = attributes.merge({ "cookie" => _cookie }) unless _cookie.nil?
      _body = { "input" => [_attributes] }
      _body.merge!({ "programName" => program }) unless program.nil?

      send_request(:post, endpoint, body: _body)
    end

    # Syncs multiple leads to marketo.
    #
    # @param leads_array [Array<Hash>] Attributes of the lead to be synced.
    # @return [Array<Hash>] The result of the sync, which usually has "id", "status" and "error" fields for each record.
    # @raise [ArgumentError] if no leads are provided
    # @raise [Marketo::ApiError] if Marketo returns an error
    def sync_multiple(leads_array)
      raise ArgumentError, "Empty leads hash, nothing to sync" if leads_array.nil? || leads_array.empty?
      endpoint = "/rest/v1/leads.json"

      body = { "input" => leads_array }

      send_request(:post, endpoint, body: body)
    end
  end
end
