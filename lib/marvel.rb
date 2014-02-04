# $LOAD_PATH << File.expand_path(File.dirname(__FILE__) + '/../lib')

require "digest/md5"
require "json"
require "her"

module Marvel

  # TODO: Let these variables come from a config file or pass them in
  PUBLIC_KEY         = ENV["MARVEL_PUBLIC_KEY"]
  PRIVATE_KEY        = ENV["MARVEL_PRIVATE_KEY"]
  TIMESTAMP          = DateTime.now.to_s
  URL_HASH           = Digest::MD5.hexdigest("#{TIMESTAMP}#{PRIVATE_KEY}#{PUBLIC_KEY}")
  DEFAULT_PARAMS     = "apikey=#{PUBLIC_KEY}&ts=#{TIMESTAMP}&hash=#{URL_HASH}"
  BASE_URL           = "http://gateway.marvel.com/v1/public"

  class MarvelError < Exception
  end

end

require "marvel/her_introspection"
require "marvel/middleware"

Her::API.setup url: Marvel::BASE_URL do |c|
  c.use Marvel::SetAuthParams        # Authentication
  c.use Faraday::Request::UrlEncoded # Request
  c.use Marvel::JsonParser           # Response
  c.use Faraday::Adapter::NetHttp    # Adapter
end

require "marvel/base"
require "marvel/character"
require "marvel/comic"
require "marvel/creator"
require "marvel/event"
require "marvel/series"
require "marvel/story"
