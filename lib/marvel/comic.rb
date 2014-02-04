class Marvel::Comic < Marvel::Base
  # Attributes => ["id", "digitalId", "title", "issueNumber", "variantDescription", "description", "modified", "isbn", "upc", "diamondCode", "ean", "issn", "format", "pageCount", "textObjects", "resourceURI", "urls", "series", "variants", "collections", "collectedIssues", "dates", "prices", "thumbnail", "images", "creators", "characters", "stories", "events"]
  has_many :characters
  has_many :creators
  has_many :events
  has_many :stories
end

