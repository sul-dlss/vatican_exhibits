require 'rails_helper'

RSpec.describe 'Indexing IIIF Annotations', type: :feature do
  before do
    stub_request(:get, 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json')
      .to_return(body: stubbed_manifest('MSS_Barb.gr.252.json'))
    stub_request(:get, 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/canvas/p0001')
      .to_return(body: stubbed_manifest('MSS_Barb.gr.252_canvas_p0001.json'))
  end

  let(:annotation) do
    Annotot::Annotation.create(
      uuid: '80b59c2e-6246-402c-959d-449aad08ddc0',
      canvas: 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/canvas/p0001',
      data: stubbed_annotation('test1.json')
    )
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:resource) { AnnotationResource.new(annotations: [annotation.to_global_id], exhibit: exhibit) }

  describe 'to_solr' do
    subject(:document) do
      resource.document_builder.to_solr.first
    end

    it 'extracts information from the Annotot resource' do
      expect(document).to include id: '80b59c2e-6246-402c-959d-449aad08ddc0',
                                  'resource_type_ssim' => ['Annotation'],
                                  'canvas_ssi' => ['https://digi.vatlib.it/iiif/MSS_Barb.gr.252/canvas/p0001']
    end

    it 'extracts information from the annotation data' do
      expect(document).to include 'type_ssi' => ['oa:Annotation'],
                                  'motivation_ssim' => ['oa:tagging', 'oa:commenting'],
                                  'annotation_text_tesim' => ['<p>test123</p>'],
                                  'annotation_tags_ssim' => ['Animali (Agnelli)'],
                                  'annotation_tags_facet_ssim' => ['Animali', 'Animali:Agnelli']
    end

    it 'extracts information from the IIIF canvas the annotation is on' do
      expect(document).to include 'canvas_label_ssi' => ['piatto.anteriore'],
                                  'iiif_image_resource_ssi' => ['https://digi.vatlib.it/iiifimage/MSS_Barb.gr.252/Barb.gr.252_0001_al_piatto.anteriore.jp2']
    end
    it 'extracts information from the IIIF manifest the canvas is contained in' do
      expect(document).to include 'iiif_manifest_ssi' => ['https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json'],
                                  'iiif_manifest_label_ssi' => ['Barb.gr.252']
    end

    it 'constructs an annotation title by concatenating manifest, canvas, and annotation data' do
      expect(document).to include 'full_title_tesim' => ['piatto.anteriore: Barb.gr.252 — test123']
    end

    it 'constructs a thumbnail that points to an annotated region of an image' do
      expect(document).to include 'thumbnail_url_ssm' => ['https://digi.vatlib.it/iiifimage/MSS_Barb.gr.252/Barb.gr.252_0001_al_piatto.anteriore.jp2/614,589,649,585/100,/0/default.jpg']
    end
  end
end
