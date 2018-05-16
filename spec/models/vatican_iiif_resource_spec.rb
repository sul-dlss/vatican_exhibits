require 'rails_helper'

RSpec.describe VaticanIiifResource do
  subject(:vatican_resource) do
    described_class.create(
      iiif_url_list: "https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json\
         \n https://digi.vatlib.it/iiif/MSS_Chig.R.V.29/manifest.json \
         \n https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json ",
      exhibit: exhibit
    )
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    # allow(harvester).to receive(:exhibit).and_return(exhibit)
    # allow(harvester).to receive(:blacklight_solr).and_return(blacklight_solr)
  end

  describe '.instance' do
    subject(:class_instance) { described_class.instance(exhibit) }

    before { class_instance.save! }

    it 'behaves like a singleton' do
      expect(described_class.instance(exhibit)).to eq class_instance
    end
  end

  describe '#resources' do
    let(:resource) { vatican_resource.resources.first }

    it do
      expect(resource).to be_a String
    end
  end

  describe '#iiif_urls' do
    it { expect(vatican_resource.iiif_urls).to be_a Array }
    it 'splits on whitespace' do
      expect(vatican_resource.iiif_urls.first).to eq 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json'
    end
    it 'is unique' do
      expect(vatican_resource.iiif_urls.count).to eq 2
    end
  end
end
