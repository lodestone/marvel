class Marvel::Series < Marvel::Base
  # Attributes => ["available", "collectionURI", "items", "returned"]
  has_many :characters
  has_many :comics
  has_many :creators
  has_many :events
  has_many :stories
end
