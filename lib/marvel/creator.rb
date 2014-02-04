class Marvel::Creator < Marvel::Base
  # Attributes => ["resourceURI", "name", "role", "comic"]
  has_many :comics
  has_many :events
  has_many :stories
end
