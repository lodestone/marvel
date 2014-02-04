class Marvel::Story < Marvel::Base
  # Attributes => ["resourceURI", "name", "type", "character"]
  has_many :characters
  has_many :comics
  has_many :creators
  has_many :events
end
