class Provider::YouTube::Downloader
  class << self

    def download(url)
      temp_dir = Rails.root.join('tmp', 'downloads')
      FileUtils.mkdir_p(temp_dir)

      filename = "#{SecureRandom.uuid}.mp3"
      output_template = temp_dir.join(filename.gsub('.mp3', '.%(ext)s')).to_s

      command = [
        'yt-dlp',
        '-x',  # Extract audio
        '--audio-format', 'mp3',
        '--audio-quality', '0',  # Best quality
        '-o', Shellwords.escape(output_template),
        url
      ].join(' ')

      `#{command}`
      raise "yt-dlp download failed for #{url}" unless $?.success?

      temp_dir.join(filename)
    end
  end
end
