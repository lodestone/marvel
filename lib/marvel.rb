require "her"
require "json"
require "digest/md5"

module Her
  module Model
    module Introspection
      extend ActiveSupport::Concern
      # Monkey patch this method to use attributes[k] instead of send
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
    puts env
    json = JSON.parse(env[:body], :symbolize_names => true)
    if json[:code] == 200
      json = json[:data][:results] || json[:data][:result]
      json.each do |j|
        j[:characters] = j[:characters][:items] if j[:characters].present?
        j[:comics]     = j[:comics][:items]     if j[:comics].present?
        j[:creators]   = j[:creators][:items]   if j[:creators].present?
        j[:events]     = j[:events][:items]     if j[:events].present?
        j[:series]     = j[:series][:items]     if j[:series].present?
        j[:stories]    = j[:stories][:items]    if j[:stories].present?
      end
      json = json.first if json.length == 1
      errors = json.delete(:errors) || {}
      metadata = json.delete(:metadata) || []
      env[:body] = { :data => json, :errors => errors, :metadata => metadata }
    else
      # TODO: Raise an error
      env[:body] = { :data => json, :errors => json[:status], :metadata => metadata }
    end
  end
end

Her::API.setup url: "https://gateway.marvel.com/v1/public" do |c|
  # Authentication
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

  def id
    resourceURI.split("/").last
  end

end

class Marvel::Character < Marvel::Base
  # Attributes => ["id", "name", "description", "modified", "thumbnail", "resourceURI", "comics", "series", "stories", "events", "urls"]
  has_many :comics
  has_many :events
  has_many :stories
end

class Marvel::Comic < Marvel::Base
  # Attributes => ["id", "digitalId", "title", "issueNumber", "variantDescription", "description", "modified", "isbn", "upc", "diamondCode", "ean", "issn", "format", "pageCount", "textObjects", "resourceURI", "urls", "series", "variants", "collections", "collectedIssues", "dates", "prices", "thumbnail", "images", "creators", "characters", "stories", "events"]
  has_many :characters
  has_many :creators
  has_many :events
  has_many :stories
end

class Marvel::Creator < Marvel::Base
  # Attributes => ["resourceURI", "name", "role", "comic"]
  has_many :comics
  has_many :events
  has_many :stories
end

class Marvel::Event < Marvel::Base
  # Attributes => ["id", "title", "description", "resourceURI", "urls", "modified", "start", "end", "thumbnail", "creators", "characters", "stories", "comics", "series", "next", "previous"]
  has_many :characters
  has_many :comics
  has_many :creators
  has_many :stories
end

class Marvel::Series < Marvel::Base
  # Attributes => ["available", "collectionURI", "items", "returned"]
  has_many :characters
  has_many :comics
  has_many :creators
  has_many :events
  has_many :stories
end

class Marvel::Story < Marvel::Base
  # Attributes => ["resourceURI", "name", "type", "character"]
  has_many :characters
  has_many :comics
  has_many :creators
  has_many :events
end

# TODO: Thumbnail class to instantiate thumbnail data in a useful way
# class Marvel::Thumbnail
# end



