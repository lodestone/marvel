require 'helper'

describe "Marvel::Character" do

  before do
    VCR.use_cassette 'spidey' do
      @spidey = Marvel::Character.find(SPIDER_MAN_ID)
    end
  end

  it "should work ok" do
    assert_equal "Spider-Man", @spidey.name
    @spidey.name.must_equal "Spider-Man"
  end

  after do
    VCR.eject_cassette 'spidey'
  end
end