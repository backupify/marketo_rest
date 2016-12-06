require 'faraday'
require 'json'

module Marketo
  class IdentityService
    attr_accessor :config
    attr_accessor :access_token
    attr_accessor :expiration

    def initialize(config = Marketo.config)
      @config = config
      @access_token = nil
      @expiration = nil
    end

    def authenticated?
      if @access_token.nil?
        false
      elsif !(@expiration.nil?) && @expiration < Time.now
        false
      else
        true
      end
    end

    def authenticate!
      params = {
        client_id: @config.client_id,
        client_secret: @config.client_secret,
        grant_type: "client_credentials"
      }

      response = Faraday.new(@config.identity_endpoint + "/oauth/token", params: params).get
      response_body = ::JSON.parse(response.body)

      expires_after = Integer(response_body["expires_in"])
      @expiration = Time.now + expires_after

      @access_token = response_body["access_token"]
    end
  end
end
