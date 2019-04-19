require 'rails_helper'

RSpec.describe VaticanIiifResourcesController, type: :controller do
  let(:resource) { double }
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  let(:attributes) do
    { iiif_url_list: "https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json\
       \n https://digi.vatlib.it/iiif/MSS_Chig.R.V.29/manifest.json" }
  end

  before do
    sign_in user
    allow(VaticanIiifResource).to receive(:find_or_initialize_by).and_return(resource)
    allow(resource).to receive(:update).with(hash_including(attributes))
    allow(resource).to receive(:save_and_index).and_return(save_status)
  end

  describe '#create' do
    context 'when save is successful' do
      let(:save_status) { true }

      it 'redirects to the exhibit' do
        post :create, params: { exhibit_id: exhibit.id, vatican_iiif_resource: attributes }

        expect(response).to redirect_to spotlight.admin_exhibit_catalog_path(exhibit)

        expect(resource).to have_received(:update)
        expect(resource).to have_received(:save_and_index)
      end
    end

    context 'when save is unsuccessful' do
      let(:save_status) { false }

      it 'redirects to the exhibit' do
        post :create, params: { exhibit_id: exhibit.id, vatican_iiif_resource: attributes }

        expect(response).to redirect_to spotlight.new_exhibit_resource_path(exhibit)

        expect(resource).to have_received(:update)
        expect(resource).to have_received(:save_and_index)
      end
    end
  end

  describe '#update' do
    context 'when save is successful' do
      let(:save_status) { true }

      it 'redirects to the exhibit' do
        patch :update, params: { exhibit_id: exhibit.id, vatican_iiif_resource: attributes }

        expect(response).to redirect_to spotlight.admin_exhibit_catalog_path(exhibit)

        expect(resource).to have_received(:update)
        expect(resource).to have_received(:save_and_index)
      end
    end

    context 'when save is unsuccessful' do
      let(:save_status) { false }

      it 'redirects to the exhibit' do
        patch :update, params: { exhibit_id: exhibit.id, vatican_iiif_resource: attributes }

        expect(response).to redirect_to spotlight.new_exhibit_resource_path(exhibit)

        expect(resource).to have_received(:update)
        expect(resource).to have_received(:save_and_index)
      end
    end
  end
end
