class VideosController < ApplicationController
  def create
    @feed = find_or_create_feed
    @video = @feed.videos.create! video_params

    VideoMetadataFetcherJob.perform_later(@video.id)
    VideoDownloaderJob.perform_later(@video.id)

    render json: {
      id: @video.id,
      feed_id: @feed.id,
      url: @video.url,
    }, status: :created
  end

  def destroy
    @video = Video.find params[:id]
    @video.destroy

    render json: @video
  end

  private

  def find_or_create_feed
    if params[:feed_id]
      Feed.find params[:feed_id]
    else
      Feed.create!(name: 'Default')
    end
  end

  def url
    params.require(:url)
  end

  def video_params
    {
      url: url,
      platform: 'youtube',
    }
  end
end
