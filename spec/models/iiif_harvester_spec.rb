require 'rails_helper'

RSpec.describe IiifHarvester do
  subject(:harvester) { described_class.new(manifest_url, tei_template_url) }

  let(:manifest_url) { 'http://example.com/manifest.json' }
  let(:tei_template_url) { 'http://example.com/{shelfmark}/tei.xml' }

  context 'when there is no manifest' do
    it 'is not #valid?' do
      expect(harvester).to receive_messages(manifest: {})

      expect(harvester).not_to be_valid
    end
  end
end
