class AudioSplicer
  require 'open3'

  class << self
    def splice(main_audio_path)
      intro_path = AudioConfig.intro_path
      return nil unless intro_path

      concat_file = nil
      output_path = Rails.root.join('tmp', 'downloads', "#{SecureRandom.uuid}_spliced.mp3")

      begin
        # Create concat file list for ffmpeg
        concat_file = create_concat_file(intro_path, main_audio_path)

        # Build ffmpeg command
        # Re-encode to ensure compatibility instead of stream copy
        command = [
          'ffmpeg',
          '-f', 'concat',
          '-safe', '0',
          '-i', concat_file.to_s,
          '-c:a', 'libmp3lame',
          '-b:a', '128k',
          '-ar', '44100',
          '-ac', '2',
          output_path.to_s
        ]

        # Execute ffmpeg
        stdout, stderr, status = Open3.capture3(*command)

        unless status.success?
          raise "ffmpeg concat failed: #{stderr}"
        end

        Rails.logger.info("Successfully spliced intro audio for #{File.basename(main_audio_path)}")
        output_path.to_s
      ensure
        # Clean up concat file
        File.delete(concat_file) if concat_file && File.exist?(concat_file)
      end
    end

    private

    def create_concat_file(intro_path, main_audio_path)
      concat_file = Rails.root.join('tmp', 'downloads', "concat_#{SecureRandom.uuid}.txt")

      # Ensure temp directory exists
      FileUtils.mkdir_p(concat_file.dirname)

      # Write concat file in ffmpeg format
      File.open(concat_file, 'w') do |f|
        f.puts "file '#{intro_path}'"
        f.puts "file '#{main_audio_path}'"
      end

      concat_file
    end
  end
end
