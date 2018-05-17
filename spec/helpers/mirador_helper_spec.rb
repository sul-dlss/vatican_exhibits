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
  end
end
