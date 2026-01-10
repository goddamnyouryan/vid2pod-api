class VideoMetadataFetcherJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    video = Video.find video_id

    metadata = Provider::YouTube::Metadata.fetch(video.url)

    video.update!(
      title: metadata[:title],
      description: metadata[:description],
      external_id: metadata[:id],
      duration: metadata[:duration_string],
      thumbnail: metadata[:thumbnail],
      published_at: Time.at(metadata[:timestamp]),
    )

    Rails.logger.info("Metadata fetched for video #{video_id}: #{metadata[:title]}")
  rescue StandardError => e
    Rails.logger.error("Metadata fetch failed for video #{video_id} (#{video.url}): #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n")) if e.backtrace

    # Re-raise for exception monitoring to capture
    raise
  end
end
