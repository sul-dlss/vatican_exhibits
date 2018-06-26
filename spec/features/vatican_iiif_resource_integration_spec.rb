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

  before do
    ['MSS_Barb.gr.252', 'MSS_Chig.R.V.29'].each do |v|
      stub_request(:get, "https://digi.vatlib.it/iiif/#{v}/manifest.json")
        .to_return(body: stubbed_manifest("#{v}.json"))
    end
    stub_request(:get, 'https://digi.vatlib.it/tei/Barb.gr.252.xml')
      .to_return(body: stubbed_tei('Barb.gr.252.xml'))
    stub_request(:get, 'https://digi.vatlib.it/tei/Chig.R.V.29.xml')
      .to_return(status: 404)
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

    it 'has a resource type' do
      expect(document['resource_type_ssim']).to eq ['Manuscript']
    end

    it 'has a title' do
      expect(document['full_title_tesim']).to eq ['Miscellanea Eunapii atque Porphyrii operum']
    end

    it 'has date' do
      expect(document['date_ssim']).to eq ['sec. xvi med', 'sec. xvi med (ff. 1-38)', 'anno 1539 (ff. 41-112)']
    end

    it 'has beginning date' do
      expect(document['beginning_date_ssim']).to eq ['1526']
    end

    it 'has ending date' do
      expect(document['ending_date_ssim']).to eq ['1575']
    end

    it 'has dated mss' do
      expect(document['dated_mss_ssim']).to eq ['1539']
    end

    it 'has author' do
      expect(document['author_ssim']).to eq ['Eunapius Sardianus', 'Porphyrius Tyrius', 'Greco']
    end

    it 'has other author' do
      expect(document['other_author_ssim']).to be_nil
    end

    it 'has other name' do
      expect(document['other_name_ssim']).to eq ['Albini, Valeriano']
    end

    it 'has place' do
      expect(document['place_ssim']).to be_nil
    end

    it 'has a language' do
      expect(document['language_ssim']).to eq ['Greco']
      expect(document['language_tesim']).to eq ['Greco']
    end

    it 'has a collection' do
      expect(document['collection_ssim']).to eq ['Barb.gr.']
      expect(document['collection_tesim']).to eq ['Barb.gr.']
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
  end
end
