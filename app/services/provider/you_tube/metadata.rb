class Provider::YouTube::Metadata
  class << self

    def fetch(url)
      command = [
        'yt-dlp',
        '--skip-download',
        "-j", # returns json dump
        Shellwords.escape(url)
      ].join(' ')

      output = `#{command}`

      raise "yt-dlp metadata fetch failed for #{url}" unless $?.success?

      JSON.parse(output, symbolize_names: true)
    end
  end
end
