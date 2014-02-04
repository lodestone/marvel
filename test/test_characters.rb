require 'helper'

describe "Marvel::Character" do

  before do
    spidey_json = `curl -is "http://gateway.marvel.com/v1/public/characters/1009610"`
    File.open("test/fixtures/spidey.json") { |f| f << spidey_json }
    # FakeWeb.register_uri(:get, "http://gateway.marvel.com/v1/public/characters/1009610", :response => page)
    # FakeWeb
    # @spidey = Marvel::Character.find(SPIDER_MAN_ID)
    # p @spidey.resourceURI
  end

  it "should work ok" do
    assert_equal "Spider-Man", @spidey.name
    @spidey.name.must_equal "Spider-Man"
  end

end

