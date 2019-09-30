require 'rails_helper'

RSpec.describe AnnotationCompatibility do
  let(:simple_fragment) do
    described_class.new(
      'on' => 'http://www.example.com/shelfmark/canvas/01#xywh=0,0,100,100'
    )
  end

  let(:complex_fragment) do
    described_class.new(
      'on' => [
        'selector' => {
          'default' => {
            '@type' => 'oa:FragmentSelector',
            'value' => 'xywh=0,0,100,100'
          }
        },
        'within' => {
          '@id' => 'http://www.example.com/shelfmark/manifest.json',
          '@type' => 'sc:Manifest'
        }
      ]
    )
  end

  describe '#manifest_uri' do
    it 'works with a simple format' do
      expect(simple_fragment.manifest_uri).to eq 'http://www.example.com/shelfmark/manifest.json'
    end

    it 'works with a complex format' do
      expect(complex_fragment.manifest_uri).to eq 'http://www.example.com/shelfmark/manifest.json'
    end
  end

  describe '#selector' do
    it 'works with a simple format' do
      expect(simple_fragment.selector).to eq(
        '@type' => 'oa:FragmentSelector',
        'value' => 'http://www.example.com/shelfmark/canvas/01#xywh=0,0,100,100'
      )
    end

    it 'works with a complex format' do
      expect(complex_fragment.selector).to eq(
        '@type' => 'oa:FragmentSelector',
        'value' => 'xywh=0,0,100,100'
      )
    end
  end
end
