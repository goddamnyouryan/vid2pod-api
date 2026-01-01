class VideoDownloaderJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    video = Video.find video_id

    download = video.create_download!(status: 'downloading')

    # Download audio to temp file
    file_path = Provider::YouTube::Downloader.download(video.url)

    # Attach to ActiveStorage
    download.file.attach(
      io: File.open(file_path),
      filename: "#{video_id}.mp3",
      content_type: 'audio/mpeg'
    )

    download.update!(status: 'completed')

    # Clean up temp file
    File.delete(file_path) if File.exist?(file_path)
  rescue StandardError => e
    download.update!(status: 'failed')
    Rails.logger.error("Download failed for video #{video_id}: #{e.message}")
    raise
  end
end
