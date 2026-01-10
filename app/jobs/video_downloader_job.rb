class VideoDownloaderJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    video = Video.find video_id

    download = video.create_download!(status: 'downloading')

    # Download audio to temp file
    file_path = Provider::YouTube::Downloader.download(video.url)

    # Attach to ActiveStorage with custom S3 key structure: feed_uuid/video_uuid.mp3
    download.file.attach(
      io: File.open(file_path),
      filename: "#{video.id}.mp3",
      content_type: 'audio/mpeg',
      key: "#{video.feed.id}/#{video.id}.mp3"
    )

    download.update!(status: 'completed')

    # Clean up temp file
    File.delete(file_path) if File.exist?(file_path)

    Rails.logger.info("Download completed for video #{video_id}: #{video.url}")
  rescue StandardError => e
    download.update!(status: 'failed')

    Rails.logger.error("Download failed for video #{video_id} (#{video.url}): #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n")) if e.backtrace

    # Re-raise for exception monitoring to capture
    raise
  end
end
