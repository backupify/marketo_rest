require 'vcr'
require 'timecop'
require 'marketo'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end

Marketo.configure do |config|
  config_file = (File.join(File.dirname(__FILE__), 'config', 'marketo.yml'))
  test_params = File.open(config_file) { |f| YAML::load(f.read) }
  config.wsdl_endpoint = test_params["wsdl_endpoint"]
  config.access_key = test_params["access_key"]
  config.secret_key = test_params["secret_key"]
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { :record => :none, :match_requests_on => [:method, :uri, :body] }
end
