require 'rails_helper'

RSpec.describe 'Bibliography resource integration test', type: :feature do
  subject(:bibliograpy_resource) do
    VaticanIiifResource.new(
      iiif_url_list: "https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json\
         \n https://digi.vatlib.it/iiif/MSS_Chig.R.V.29/manifest.json",
      exhibit: exhibit
    )
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }

  it 'can write the document to solr' do
    expect { bibliograpy_resource.reindex }.not_to raise_error
  end

  describe 'to_solr' do
    subject(:document) do
      bibliograpy_resource.document_builder.to_solr.first
    end

    it 'has a doc id' do
      expect(document['id']).to eq ['MSS_Barb_gr_252']
    end

    it 'has iiif manifest' do
      expect(document['iiif_manifest_url_ssi']).to eq ['https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json']
    end

    it 'has spotlight data' do
      expect(document).to include :spotlight_resource_id_ssim
    end
  end
end
