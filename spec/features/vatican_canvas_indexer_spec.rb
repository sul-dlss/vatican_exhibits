require 'rails_helper'

RSpec.describe 'Vatican canvas resource integration test', type: :feature do
  subject(:canvas_resource) do
    CanvasResource.new(
      annotations: [load_annotation('test1.json')],
      label: 'piatto.anteriore',
      exhibit: exhibit
    )
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }

  it 'can write the document to solr' do
    expect { canvas_resource.reindex }.not_to raise_error
  end

  describe 'to_solr' do
    subject(:document) do
      canvas_resource.document_builder.to_solr.first
    end

    it 'has a doc id' do
      expect(document['id']).to eq ['canvas-d41d8cd98f00b204e9800998ecf8427e']
    end

    it 'has a title' do
      expect(document['full_title_tesim']).to eq ['piatto.anteriore']
    end

    it 'has annotation tags' do
      expect(document['annotation_tags_ssim'].first).to eq 'Animali (Agnelli)'
    end

    it 'has spotlight data' do
      expect(document).to include :spotlight_resource_id_ssim
    end
  end
end
