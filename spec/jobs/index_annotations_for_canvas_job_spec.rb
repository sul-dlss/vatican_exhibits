require 'rails_helper'

RSpec.describe IndexAnnotationsForCanvasJob do
  let(:annotation) { FactoryBot.create(:annotation) }

  describe '#perform' do
    context 'with a canvas that has no annotations' do
      it 'is a no-op' do
        described_class.perform_now('some-canvas-uri')
      end
    end

    context 'with a canvas that has an annotation' do
      it 'queues the annotation for indexing' do
        allow(IndexAnnotationJob).to receive(:perform_later)
        described_class.perform_now('http://www.example.com/hola')
        expect(IndexAnnotationJob).to have_received(:perform_later).with(annotation)
      end
    end
  end
end
