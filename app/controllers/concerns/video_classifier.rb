class VideoClassifier
  attr_accessor :url

  def initialize(url)
    @url = url
  end

  def link_type
    :video
  end

  def platform
    'youtube'
  end
end
