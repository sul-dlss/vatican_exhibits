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
  # let(:annotation) do
  # 
  # end

  before do
    ['MSS_Barb.gr.252', 'MSS_Chig.R.V.29'].each do |v|
      stub_request(:get, "https://digi.vatlib.it/iiif/#{v}/manifest.json")
        .to_return(body: stubbed_manifest("#{v}.json"))
    end
    stub_request(:get, 'https://digi.vatlib.it/tei/Barb.gr.252.xml')
      .to_return(body: stubbed_tei('Barb.gr.252.xml'))
    stub_request(:get, 'https://digi.vatlib.it/tei/Chig.R.V.29.xml')
      .to_return(status: 404)
    FactoryBot.create(
      :annotation,
      canvas: 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/canvas/p0001',
      data: load_annotation('test1.json')
    )
  end

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

    it 'has a title' do
      expect(document['full_title_tesim']).to eq ['Miscellanea Eunapii atque Porphyrii operum']
    end

    it 'has a watermark' do
      expect(document['watermark_tesim'].first).to include('In prima parte codicis')
    end

    it 'has a colophon' do
      expect(document['colophon_tesim'].first).to include('Ἀδελφὸς Οὐαλεριᾶνος Φορολιβιεὺς')
    end

    it 'has iiif manifest' do
      expect(document['iiif_manifest_url_ssi']).to eq ['https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json']
    end

    it 'has spotlight data' do
      expect(document).to include :spotlight_resource_id_ssim
    end

    it 'has annotation tags' do
      expect(document['annotation_tags_ssim'].first).to include('Animali (Agnelli)')
    end
  end
end
