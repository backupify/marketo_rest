module Marketo
  class Config < Struct.new(:rest_endpoint, :identity_endpoint, :client_id, :client_secret)

    def self.default
      new
    end

    def merge_params!(other_params)
      other_params.each { |key, value| send("#{key}=", value) }
    end
  end
end
