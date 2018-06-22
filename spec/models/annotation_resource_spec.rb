require 'rails_helper'

RSpec.describe AnnotationResource do
  subject(:resource) { described_class.new(annotations: [annotation.to_global_id]) }

  let(:annotation) { FactoryBot.create(:annotation) }

  describe '#resources' do
    it 're-hydrates a list of annotation ids' do
      expect(resource.resources).to match_array [annotation]
    end
  end

  describe '#delete_from_index' do
    let(:blacklight_solr) { resource.send(:blacklight_solr) }

    before do
      allow(blacklight_solr).to receive(:delete_by_query)
    end

    it 'deletes the annotation from the index' do
      resource.delete_from_index
      expect(blacklight_solr).to have_received(:delete_by_query).with("id:#{annotation.uuid}")
    end
  end
end
