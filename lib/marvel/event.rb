class Marvel::Event < Marvel::Base
  # Attributes => ["id", "title", "description", "resourceURI", "urls", "modified", "start", "end", "thumbnail", "creators", "characters", "stories", "comics", "series", "next", "previous"]
  has_many :characters
  has_many :comics
  has_many :creators
  has_many :stories
end
