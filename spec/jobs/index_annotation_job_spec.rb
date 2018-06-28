require 'rails_helper'

RSpec.describe IndexAnnotationJob do
  let(:stub_resource) { instance_double(AnnotationResource, delete_from_index: nil, reindex: nil) }
  let(:annotation) { FactoryBot.create(:annotation, data: annotation_data) }
  let(:annotation_data) do
    {
      'on' => [{
        'within' => {
          '@id' => 'x'
        }
      }]
    }
  end

  describe '#perform' do
    context 'with an annotation not on a resource in the exhibit' do
      it 'is a no-op' do
        described_class.perform_now(annotation)
      end
    end

    context 'with an annotation on a resource associated with an exhibit' do
      let(:exhibit) { FactoryBot.create(:exhibit) }

      before do
        allow(AnnotationResource).to receive(:new).with(exhibit: exhibit,
                                                        annotations: [annotation.to_global_id]).and_return(stub_resource)
        VaticanIiifResource.instance(exhibit).update(iiif_url_list: 'x')
      end

      it 'indexes the item' do
        described_class.perform_now(annotation)
        expect(stub_resource).to have_received(:reindex)
      end
    end

    context 'with a deleted annotation' do
      before do
        annotation.destroy
        allow(AnnotationResource).to receive(:new).with(exhibit: nil,
                                                        annotations: [annotation.to_global_id]).and_return(stub_resource)
      end

      it 'deletes objects from the index' do
        described_class.perform_now(annotation)
        expect(stub_resource).to have_received(:delete_from_index)
      end
    end
  end
end
