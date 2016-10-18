require "savon"
require "openssl/digest"

require "marketo/client"
require "marketo/interface"
require "marketo/lead"
require "marketo/config"

module Marketo
  extend self

  def configure
    yield config
  end

  def config
    @config ||= Config.default
  end
end
