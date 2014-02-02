require "her"
require "json"
require "digest/md5"

module Her
  module Model
    module Introspection
      extend ActiveSupport::Concern
      def inspect
        resource_path = begin
          request_path
        rescue Her::Errors::PathError => e
          "<unknown path, missing `#{e.missing_parameter}`>"
        end

        "#<#{self.class}(#{resource_path}) #{attributes.keys.map { |k| "#{k}=#{attribute_for_inspect(attributes[k])}" }.join(" ")}>"
      end
    end
  end
end

# TODO: Let these variables come from a config file
MARVEL_PUBLIC_KEY  = ENV["MARVEL_PUBLIC_KEY"]
MARVEL_PRIVATE_KEY = ENV["MARVEL_PRIVATE_KEY"]
MARVEL_TIMESTAMP   = DateTime.now.to_s
MARVEL_HASH        = Digest::MD5.hexdigest("#{MARVEL_TIMESTAMP}#{MARVEL_PRIVATE_KEY}#{MARVEL_PUBLIC_KEY}")
DEFAULT_PARAMS     = "apikey=#{MARVEL_PUBLIC_KEY}&ts=#{MARVEL_TIMESTAMP}&hash=#{MARVEL_HASH}"

class SetAuthParams < Faraday::Middleware
  def call(env)
    env[:url].query = DEFAULT_PARAMS
    @app.call(env)
  end
end

class MarvelParser < Faraday::Response::Middleware
  def on_complete(env)
    json = JSON.parse(env[:body], :symbolize_names => true)
    json = json[:data][:results] || json[:data][:result]
    errors = json.delete(:errors) || {}
    metadata = json.delete(:metadata) || []
    env[:body] = { :data => json, :errors => errors, :metadata => metadata }
  end
end

Her::API.setup url: "https://gateway.marvel.com/v1/public" do |c|
  c.use SetAuthParams
  # Request
  c.use Faraday::Request::UrlEncoded
  # Response
  c.use MarvelParser
  # Adapter
  c.use Faraday::Adapter::NetHttp
end

module Marvel;end


# TODO: Watch these and see if they make sense breaking out into separate files
class Marvel::Base
  include Her::Model
end

class Marvel::Character < Marvel::Base
end

class Marvel::Comic < Marvel::Base
end

class Marvel::Creator < Marvel::Base
end

class Marvel::Event < Marvel::Base
end

class Marvel::Series < Marvel::Base
end

class Marvel::Story < Marvel::Base
end




