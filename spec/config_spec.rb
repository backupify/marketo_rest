require "marketo/config"
describe Marketo do
  describe Marketo::Config do
    describe "default" do
      it "should return structure with default values" do
        result = Marketo::Config.default
        expect(result.client_id).to be_nil
        expect(result.client_secret).to be_nil
        expect(result.rest_endpoint).to be_nil
        expect(result.identity_endpoint).to be_nil
      end
    end

    describe "merge_params!" do
      it "merges hash of params to existing config" do
        test_hash = { client_id: "some_key",
                      client_secret: "some_secret",
                      rest_endpoint: "https://123-ABC-001.mktorest.com/rest",
                      identity_endpoint: "https://123-ABC-001.mktorest.com/identity"
                    }

        config_hash = Marketo::Config.default
        config_hash.merge_params!(test_hash)
        expect(config_hash.client_id).to eq(test_hash[:client_id])
        expect(config_hash.client_secret).to eq(test_hash[:client_secret])
        expect(config_hash.rest_endpoint).to eq(test_hash[:rest_endpoint])
        expect(config_hash.identity_endpoint).to eq(test_hash[:identity_endpoint])
      end
    end
  end
end
