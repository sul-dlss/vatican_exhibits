require 'rails_helper'

RSpec.describe SolrDocument do
  subject(:document) { described_class.new(data) }

  let(:data) { {} }

  describe '#related_annotations' do
    context 'with a manuscript' do
      it 'is empty for non-annotation documents' do
        expect(document.related_annotations).to be_empty
      end
    end

    context 'with an annotation' do
      let(:data) { { resource_type_ssim: ['Annotation'], canvas_ssi: canvas_uri, uuid: 'c' } }
      let(:canvas_uri) { 'x' }

      before do
        FactoryBot.create(:annotation, uuid: 'a', canvas: canvas_uri)
        FactoryBot.create(:annotation, uuid: 'b', canvas: canvas_uri)
      end

      it 'returns other annotations on that canvas' do
        expect(document.related_annotations.pluck(:uuid)).to match_array %w[a b]
      end
    end
  end
end
