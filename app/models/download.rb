class Download < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :video
  has_one_attached :file

  validates :status, inclusion: { in: %w[pending downloading completed failed] }

  def file_url
    return nil unless file.attached?

    # In production, this will use the CloudFront CDN (downloads.vid2pod.fm)
    # via the asset_host configured in production.rb
    # In development, this will use localhost
    if Rails.env.production?
      # Use CloudFront URL for production
      rails_blob_url(file, host: 'downloads.vid2pod.fm', protocol: 'https')
    else
      # Use localhost for development
      rails_blob_url(file, host: 'localhost', protocol: 'http', port: 3000)
    end
  end
end
