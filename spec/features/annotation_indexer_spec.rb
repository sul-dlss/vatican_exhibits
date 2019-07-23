require 'rails_helper'

RSpec.describe 'Indexing IIIF Annotations', type: :feature do
  before do
    stub_request(:get, 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json')
      .to_return(body: stubbed_manifest('MSS_Barb.gr.252.json'))
    stub_request(:get, 'https://digi.vatlib.it/rotation/MSS_Pal.lat.24/manifest.json')
      .to_return(body: stubbed_manifest('Rotated_MSS_Pal.lat.24.json'))
  end

  let(:annotation) do
    Annotot::Annotation.create(
      uuid: '80b59c2e-6246-402c-959d-449aad08ddc0',
      canvas: 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/canvas/p0001',
      data: stubbed_annotation('test1.json')
    )
  end

  let(:annotation_on_rotation) do
    Annotot::Annotation.create(
      uuid: 'cb5979f5-8aae-419b-b749-0290b0c06b62',
      canvas: 'https://digi.vatlib.it/Pal.lat.24inf01b',
      data: stubbed_annotation('test_rotated.json')
    )
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:resource) { AnnotationResource.new(annotations: [annotation.to_global_id, 'foo'], exhibit: exhibit) }
  let(:rotated_resource) { AnnotationResource.new(annotations: [annotation_on_rotation.to_global_id, 'bar'], exhibit: exhibit) }

  describe 'to_solr' do
    subject(:document) do
      resource.document_builder.to_solr.first
    end

    it 'skips missing annotations' do
      expect(resource.document_builder.to_solr).to all(be_an(Hash))
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
                                  'annotation_tags_it_ssim' => ['Animali (Agnelli)'],
                                  'annotation_tags_facet_it_ssim' => ['Animali', 'Animali:Agnelli']
    end

    it 'has translations for annotation tags' do
      expect(document).to include 'annotation_tags_en_ssim' => ['Animals (Lambs)'],
                                  'annotation_tags_facet_en_ssim' => ['Animals', 'Animals:Lambs']
    end

    it 'extracts information from the IIIF canvas the annotation is on' do
      expect(document).to include 'canvas_label_ssi' => ['piatto.anteriore'],
                                  'iiif_image_resource_ssi' => ['https://digi.vatlib.it/iiifimage/MSS_Barb.gr.252/Barb.gr.252_0001_al_piatto.anteriore.jp2']
    end
    it 'extracts information from the IIIF manifest the canvas is contained in' do
      expect(document).to include 'iiif_manifest_url_ssi' => ['https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json'],
                                  'iiif_manifest_label_ssi' => ['Barb.gr.252'],
                                  'manuscript_shelfmark_ssim' => ['Barb.gr.252']
    end

    it 'extracts information from the IIIF structure the canvas is contained in' do
      expect(document).to include 'iiif_structure_label_ssim' => ['Legatura <inf.>'],
                                  'iiif_structure_id_ssim' => ['https://digi.vatlib.it/iiif/MSS_Barb.gr.252/range/r0-0']
    end

    it 'constructs an annotation title by concatenating manifest, canvas, and annotation data' do
      expect(document).to include 'full_title_tesim' => ['piatto.anteriore: Barb.gr.252 — test123']
    end

    it 'constructs a thumbnail that points to an annotated region of an image' do
      expect(document).to include 'thumbnail_url_ssm' => ['https://digi.vatlib.it/iiifimage/MSS_Barb.gr.252/Barb.gr.252_0001_al_piatto.anteriore.jp2/614,589,649,585/100,/0/default.jpg']
    end
    describe('rotated annotation manifest') do
      subject(:rotated_document) do
        rotated_resource.document_builder.to_solr.first
      end

      it('constructs a thumbnail that points to a rotated full image') do
        expect(rotated_document).to include 'thumbnail_url_ssm' => ['https://digi.vatlib.it/iiifimage/MSS_Pal.lat.24/Pal.lat.24_0199_fa_0043v.%5B02.wl.0000%5D.jp2/0,0,2115,3225/100,/180/native.jpg']
      end
    end
  end
end
