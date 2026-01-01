class YtDlpService
  class << self
    def fetch_metadata(url)
      # Use yt-dlp to fetch metadata without downloading
      command = [
        'yt-dlp',
        '--dump-json',
        '--no-playlist',
        Shellwords.escape(url)
      ].join(' ')

      output = `#{command}`
      raise "yt-dlp metadata fetch failed for #{url}" unless $?.success?

      # Parse JSON output
      JSON.parse(output, symbolize_names: true)
    rescue Errno::ENOENT
      raise "yt-dlp is not installed. Please install it with: brew install yt-dlp"
    rescue JSON::ParserError => e
      raise "Failed to parse yt-dlp output: #{e.message}"
    end

    def download_audio(video_id)
      # Create temp directory for download
      temp_dir = Rails.root.join('tmp', 'downloads')
      FileUtils.mkdir_p(temp_dir)

      # Generate unique filename
      filename = "#{SecureRandom.uuid}.mp3"
      output_template = temp_dir.join(filename.gsub('.mp3', '.%(ext)s')).to_s

      # Download audio
      command = [
        'yt-dlp',
        '-x',  # Extract audio
        '--audio-format', 'mp3',
        '--audio-quality', '0',  # Best quality
        '-o', Shellwords.escape(output_template),
        "https://www.youtube.com/watch?v=#{video_id}"
      ].join(' ')

      `#{command}`
      raise "yt-dlp download failed for video #{video_id}" unless $?.success?

      # Return the path to the downloaded file
      temp_dir.join(filename)
    rescue Errno::ENOENT
      raise "yt-dlp is not installed. Please install it with: brew install yt-dlp"
    end
  end
end
