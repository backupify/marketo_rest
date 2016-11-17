require 'vcr'
require 'yaml'
require 'timecop'
require 'marketo'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

def load_test_config
  config_file = (File.join(File.dirname(__FILE__), 'config', 'marketo.yml'))
  File.open(config_file) { |f| YAML::load(f.read) }
end

Marketo.configure do |config|
  test_config = load_test_config

  config.rest_endpoint = test_config["rest_endpoint"]
  config.identity_endpoint = test_config["identity_endpoint"]
  config.client_id = test_config["client_id"]
  config.client_secret = test_config["client_secret"]
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { :record => :none, :match_requests_on => [:method, :uri, :body] }
  c.configure_rspec_metadata!
end
