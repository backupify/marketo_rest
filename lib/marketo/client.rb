module Marketo
  class Client
    extend Savon::Model

    actions :describe_m_object, :get_campaigns_for_source, :get_lead, :get_lead_activity, :get_lead_changes, :get_multiple_leads, :list_m_objects, :list_operation, :request_campaign, :sync_lead, :sync_multiple_leads

    attr_accessor :client
    attr_accessor :header
    attr_accessor :cookie

    def self.new_marketo_client(params = {})
      config = Marketo.config
      config.merge_params!(params)

      @client = Savon::Client.new do
        http.headers["Pragma"] = "no-cache"
        wsdl.endpoint = config.wsdl_endpoint
        wsdl.document = config.wsdl_document
      end

      @client.config.soap_version = 1
      @client.http.open_timeout = 240
      @client.http.read_timeout = 240
      @header = AuthenticationHeader.new(config.access_key, config.secret_key)

      Interface.new(@client, @header)
    end
  end
end
