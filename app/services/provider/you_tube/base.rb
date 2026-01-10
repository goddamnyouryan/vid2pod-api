class Provider::YouTube::Base
  require 'open3'
  require 'shellwords'

  class << self
    private

    def write_cookies_file
      cookies_content = ENV['YOUTUBE_COOKIES']
      if cookies_content.blank?
        raise "YOUTUBE_COOKIES environment variable not set. See docs for cookie export instructions."
      end

      cookies_file = Rails.root.join('tmp', "cookies_#{SecureRandom.uuid}.txt")
      File.write(cookies_file, cookies_content)
      cookies_file
    end

    def cleanup_cookies_file(cookies_file)
      File.delete(cookies_file) if cookies_file && File.exist?(cookies_file)
    end

    def user_agent
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
    end

    def parse_error(stderr)
      case stderr
      when /Sign in to confirm you're not a bot/, /Sign in to confirm your age/
        "YouTube bot detection - cookies may be invalid or expired"
      when /No supported JavaScript runtime/
        "JavaScript runtime not found - check Heroku buildpacks"
      when /Video unavailable/, /This video is unavailable/
        "Video is unavailable or removed"
      when /Private video/
        "Video is private"
      when /429/
        "Rate limited by YouTube - too many requests"
      when /Cookies file is invalid/
        "Cookie file format is invalid - must be Netscape format"
      else
        stderr.lines.first&.strip || "Unknown error"
      end
    end
  end
end
