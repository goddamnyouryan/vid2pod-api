class Provider::YouTube::Metadata < Provider::YouTube::Base
  class << self
    def fetch(url)
      cookies_file = write_cookies_file

      command = build_command(url, cookies_file)

      stdout, stderr, status = Open3.capture3(command)

      unless status.success?
        error_message = parse_error(stderr)
        cleanup_cookies_file(cookies_file)
        raise "yt-dlp metadata fetch failed for #{url}: #{error_message}"
      end

      cleanup_cookies_file(cookies_file)
      JSON.parse(stdout, symbolize_names: true)
    end

    private

    def build_command(url, cookies_file)
      [
        'yt-dlp',
        '--js-runtimes', 'node',
        '--cookies', cookies_file.to_s,
        '--user-agent', user_agent,
        '--skip-download',
        '-j',  # returns json dump
        url
      ]
    end
  end
end
