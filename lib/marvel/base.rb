class Marvel::Base

  include Her::Model

  def id
    resourceURI.split("/").last
  end

  # def url; resourceURI; end

end
