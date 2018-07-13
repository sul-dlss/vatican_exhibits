require 'rails_helper'

RSpec.describe MiradorHelper, type: :helper do
  let(:manifest) { 'https://example.edu/manifest.json' }
  let(:canvas) { 'https://example.edu/manifest1/canvas1' }

  describe 'mirador settings propagation' do
    it 'includes the manifest url in the data array' do
      mirador_options = mirador_options(manifest, canvas)
      expect(mirador_options[:data].first[:manifestUri]).to be manifest
    end
    it 'includes the manifest url and canvas uri in the windowObject' do
      mirador_options = mirador_options(manifest, canvas)
      expect(mirador_options[:windowObjects].first[:loadedManifest]).to be manifest
      expect(mirador_options[:windowObjects].first[:canvasID]).to be canvas
    end
    context 'with no canvas' do
      it 'turns off annotationState' do
        mirador_options = mirador_options(manifest, nil)
        expect(
          mirador_options[:windowObjects].first[:canvasControls][:annotations][:annotationState]
        ).to eq 'off'
      end
    end

    context 'with canvas' do
      it 'turns on annotationState' do
        mirador_options = mirador_options(manifest, canvas)
        expect(
          mirador_options[:windowObjects].first[:canvasControls][:annotations][:annotationState]
        ).to eq 'on'
      end
    end

    it 'configures AnnototEndpoint' do
      mirador_options = mirador_options(manifest, nil)
      expect(mirador_options[:annotationEndpoint][:module]).to eq 'AnnototEndpoint'
      expect(mirador_options[:annotationEndpoint][:options][:endpoint]).to eq '/annotations'
    end
  end
end
