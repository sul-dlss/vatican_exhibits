require 'rails_helper'

RSpec.describe 'Annotation Requests', type: :request do
  context 'without an API key' do
    it 'index returns annotations' do
      get '/annotations', params: { uri: 'http://example.com/canvas' }
      expect(response.content_type).to eq('application/json')
      expect(JSON.parse(response.body)).to eq []
      expect(response).to have_http_status(:ok)
    end
    it 'list returns annotations' do
      get '/annotations/lists', params: { uri: 'http://example.com/canvas' }
      expect(response.content_type).to eq('application/json')
      expect(response).to have_http_status(:ok)
    end
    it 'update raises unauthorized' do
      expect do
        patch '/annotations/1', params: { uri: 'http://example.com/canvas' }
      end.to raise_error ApiAuthorization::Unauthorized
    end
    it 'destroy raises unauthorized' do
      expect do
        delete '/annotations/1', params: { uri: 'http://example.com/canvas' }
      end.to raise_error ApiAuthorization::Unauthorized
    end
    it 'post raises unauthorized' do
      expect do
        post '/annotations', params: { uri: 'http://example.com/canvas' }
      end.to raise_error ApiAuthorization::Unauthorized
    end
  end
  context 'with an API key' do
    let(:anno) { FactoryBot.create(:annotation) }
    let(:valid_attributes) do
      {
        data: 'super cool anno data',
        canvas: 'http://example.com/canvas'
      }
    end

    it 'update successfully updates' do
      patch "/annotations/#{anno.id}",
            params: { format: :json, annotation: valid_attributes },
            headers: { 'Authorization' => 'test123' }
      expect(response.content_type).to eq('application/json')
      anno.reload
      expect(anno.data).to eq 'super cool anno data'
    end
    it 'destroy raises unauthorized' do
      delete "/annotations/#{anno.id}",
             params: { format: :json },
             headers: { 'Authorization' => 'test123' }
      expect(response.status).to be 200
    end
    it 'post creates a new annotation' do
      post '/annotations',
           params: { format: :json, annotation: valid_attributes.merge(uuid: 'abc123') },
           headers: { 'Authorization' => 'test123' }
      expect(response.status).to be 200
    end
  end
end
