require 'rails_helper'

RSpec.describe 'Mirador Block', type: :feature, js: true do
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    sign_in user
  end

  describe 'basic content' do
    it 'renders the title, text, and caption' do
      visit spotlight.edit_exhibit_home_page_path(exhibit)

      add_widget 'mirador'

      choose 'IIIF manifest'
      input = find('[data-behavior="source-location-input"]', visible: true)
      expect(input['placeholder']).to eq 'Enter a IIIF manifest URL...'

      input.set('http://example.com/manifest.json')
      click_link 'Load IIIF item'

      hidden_input = find('input[type="hidden"][name="items[item_0][iiif_manifest_url]"]', visible: false)
      expect(hidden_input['value']).to eq 'http://example.com/manifest.json'

      page.all('input[name="heading"]').first.set('The Heading')
      page.all('textarea[name="text"]').first.set('The Text')
      page.all('input[name="caption"]').first.set('The Caption')

      save_page

      expect(page).to have_content 'The Heading'
      expect(page).to have_content 'The Text'
      expect(page).to have_content 'The Caption'
    end
  end

  describe 'mirador config' do
    let(:mirador_config) do
      {
        language: 'en',
        data: [
          {
            manifestUri: 'http://example.com/manifest.json'
          }
        ],
        layout: '1x1',
        windowObjects: [
          {
            loadedManifest: 'http://example.com/manifest.json',
            viewType: 'ImageView'
          }
        ]
      }.to_json
    end

    it 'renders a usable Mirador configuration' do
      visit spotlight.edit_exhibit_home_page_path(exhibit)

      add_widget 'mirador'

      choose 'IIIF manifest'
      input = find('[data-behavior="source-location-input"]', visible: true)
      input.set('http://example.com/manifest.json')
      click_link 'Load IIIF item'
      hidden_input = find('input[type="hidden"][name="mirador_config"]', visible: false)

      expect(hidden_input['value']).to eq mirador_config
    end
  end
end
