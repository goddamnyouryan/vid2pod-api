class VideoDownloaderJob < ApplicationJob
  queue_as :default

  def perform(video_id, reprocess: false)
    video = Video.find video_id

    download = if reprocess
      video.download.tap do |d|
        d.update!(status: 'downloading')
        d.file.purge if d.file.attached?
      end
    else
      video.create_download!(status: 'downloading')
    end

    process_download(video, download)

    Rails.logger.info("#{reprocess ? 'Reprocessing' : 'Download'} completed for video #{video_id}: #{video.url}")
  rescue StandardError => e
    download&.update!(status: 'failed')

    Rails.logger.error("#{reprocess ? 'Reprocessing' : 'Download'} failed for video #{video_id} (#{video.url}): #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n")) if e.backtrace

    # Re-raise for exception monitoring to capture
    raise
  end

  private

  def process_download(video, download)
    # Download audio to temp file
    file_path = Provider::YouTube::Downloader.download(video.url)

    # Splice intro audio
    spliced_file_path = AudioSplicer.splice(file_path)
    final_path = spliced_file_path || file_path

    # Attach to ActiveStorage with custom S3 key structure: feed_uuid/video_uuid.mp3
    download.file.attach(
      io: File.open(final_path),
      filename: "#{video.id}.mp3",
      content_type: 'audio/mpeg',
      key: "#{video.feed.id}/#{video.id}.mp3"
    )

    download.update!(status: 'completed')

    # Clean up temp files
    File.delete(file_path) if File.exist?(file_path)
    File.delete(spliced_file_path) if spliced_file_path && File.exist?(spliced_file_path)
  end
end
