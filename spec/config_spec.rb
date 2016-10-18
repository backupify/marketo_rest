require "marketo/config"
describe Marketo do
  describe Marketo::Config do
    describe "default" do
      it "should return structure with default values" do
        result = Marketo::Config.default
        result.wsdl_document.should == "https://app.marketo.com/soap/mktows/2_2?WSDL"
        result.access_key.should be_nil
        result.secret_key.should be_nil
        result.wsdl_endpoint.should be_nil
      end
    end

    describe "merge_params!" do
      it "merges hash of params to existing config" do
        test_hash = { access_key: "some_key",
                      secret_key: "some_secret",
                      wsdl_endpoint: "https://some.mktoapi.com/soap/mktows/2_2"
                    }
        config_hash = Marketo::Config.default
        config_hash.merge_params!(test_hash)
        config_hash.wsdl_document.should == "https://app.marketo.com/soap/mktows/2_2?WSDL"
        config_hash.access_key.should == "some_key"
        config_hash.secret_key.should == "some_secret"
        config_hash.wsdl_endpoint.should == "https://some.mktoapi.com/soap/mktows/2_2"
      end
    end
  end
end
