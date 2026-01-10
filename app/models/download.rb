class Download < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :video
  has_one_attached :file

  validates :status, inclusion: { in: %w[pending downloading completed failed] }

  def file_url
    return nil unless file.attached?

    if Rails.env.production?
      # Use direct CloudFront URL with custom S3 object key
      # file.key returns the custom key: "feed_uuid/video_uuid.mp3"
      # Example URL: https://downloads.vid2pod.fm/abc123-feed-uuid/def456-video-uuid.mp3
      "https://downloads.vid2pod.fm/#{file.key}"
    else
      # Use localhost Rails routing for development
      rails_blob_url(file, host: 'localhost', protocol: 'http', port: 3000)
    end
  end
end
