require "marketo/client"
require "marketo/interface"
require "marketo/identity_service"
require "marketo/config"
require "marketo/api_error"

module Marketo
  extend self

  def configure
    yield config
  end

  def config
    @config ||= Config.default
  end
end
