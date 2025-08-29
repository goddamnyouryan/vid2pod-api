class ApplicationController < ActionController::API
  def default
    render json: { error: 'This is the default url for the vid2pod API service.' }
  end
end
