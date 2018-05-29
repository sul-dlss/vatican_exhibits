require 'rails_helper'

RSpec.describe IiifHarvester do
  subject(:harvester) { described_class.new(manifest_url) }

  let(:manifest_url) { 'http://example.com/manifest.json' }

  context 'when there is no manifest' do
    it 'is not #valid?' do
      expect(harvester).to receive_messages(manifest: {})

      expect(harvester).not_to be_valid
    end
  end

  context 'when there is a manifest' do
    it 'is #valid?' do
      expect(harvester).to receive_messages(manifest: { '@id' => 'howdy' })

      expect(harvester).to be_valid
    end

    describe 'thumbnails' do
      context 'when there are no sequences' do
        it 'is an empty array' do
          expect(harvester).to receive_messages(manifest: { '@id' => 'howdy' })

          expect(harvester.thumbnails).to be_empty
        end
      end

      context 'when a sequence has no canvas' do
        it 'does not include that sequence' do
          expect(harvester).to receive_messages(
            manifest: {
              '@id' => 'howdy',
              'sequences' => [
                {
                  '@id' => 'sequenceid1'
                }
              ]
            }
          )

          expect(harvester.thumbnails).to be_empty
        end
      end

      context 'when a canvas does not have a thumbnail with an @id' do
        it 'they are not included in the thumbnail array' do
          expect(harvester).to receive_messages(
            manifest: {
              '@id' => 'howdy',
              'sequences' => [
                {
                  '@id' => 'sequenceid1',
                  'canvases' => [{ 'thumbnail' => { 'desc' => 'invalid thumb' } }]
                }
              ]
            }
          )

          expect(harvester.thumbnails).to be_empty
        end
      end

      context 'when canvases have thumbnails' do
        it 'they are included in the thubnails array' do
          expect(harvester).to receive_messages(
            manifest: {
              '@id' => 'howdy',
              'sequences' => [
                {
                  '@id' => 'sequenceid1',
                  'canvases' => [
                    { 'thumbnail' => { '@id' => 'http://example.com/pup.gif' } },
                    { 'thumbnail' => { '@id' => 'http://example.com/cat.gif' } }
                  ]
                },
                {
                  '@id' => 'sequenceid2',
                  'canvases' => [
                    { 'thumbnail' => { '@id' => 'http://example.com/coolcat.gif' } }
                  ]
                }
              ]
            }
          )

          expect(harvester.thumbnails.length).to eq 3
          expect(harvester.thumbnails).to include 'http://example.com/pup.gif'
          expect(harvester.thumbnails).to include 'http://example.com/cat.gif'
          expect(harvester.thumbnails).to include 'http://example.com/coolcat.gif'
        end
      end
    end
  end
end
