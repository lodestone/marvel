class Marvel::Character < Marvel::Base
  # Attributes => ["id", "name", "description", "modified", "thumbnail", "resourceURI", "comics", "series", "stories", "events", "urls"]
  has_many :comics
  has_many :events
  has_many :stories
end

