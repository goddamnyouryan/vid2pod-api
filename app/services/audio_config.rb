class AudioConfig
  class << self
    def intro_path
      path = Rails.root.join('app', 'audio', 'intro.mp3')
      path if File.exist?(path)
    end

    def intro_exists?
      intro_path.present?
    end

    def splicing_enabled?
      intro_exists?
    end
  end
end
