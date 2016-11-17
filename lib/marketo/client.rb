module Marketo
  class Client
    OPEN_TIMEOUT = 2
    RESPONSE_TIMEOUT = 30

    def self.new_marketo_client(params = {})
      config = Marketo.config
      config.merge_params!(params)

      @client = Faraday.new(url: config.rest_endpoint, request: {
        open_timeout: OPEN_TIMEOUT,
        timeout: RESPONSE_TIMEOUT
      })
      @identity_service = IdentityService.new(config)

      Interface.new(@client, @identity_service)
    end
  end
end
