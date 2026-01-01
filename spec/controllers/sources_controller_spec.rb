require 'rails_helper'

RSpec.describe SourcesController, type: :controller do
  describe 'POST #create' do
    let(:valid_params) do
      { url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ' }
    end

    context 'when creating a source with valid parameters' do
      it 'creates a new source associated with the default feed' do
        expect {
          post :create, params: valid_params
        }.to change(Source, :count).by(1)
      end

      it 'creates the source with the correct attributes' do
        post :create, params: valid_params

        source = Source.last
        expect(source.url).to eq('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
        expect(source.source_type).to eq('video')
        expect(source.platform).to eq('youtube')
      end

      it 'associates the source with the default feed' do
        post :create, params: valid_params

        source = Source.last
        expect(source.feed).to be_present
        expect(source.feed.name).to eq('Default')
      end

      it 'finds or creates the default feed' do
        expect {
          post :create, params: valid_params
        }.to change(Feed, :count).by(1)

        expect {
          post :create, params: valid_params
        }.not_to change(Feed, :count)
      end
    end
  end
end
