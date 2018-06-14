require 'rails_helper'

RSpec.describe 'Mirador Block', type: :feature, js: true do
  let(:user) { FactoryBot.create(:exhibit_admin, exhibit: exhibit) }
  let(:exhibit) { FactoryBot.create(:exhibit, slug: 'default-exhibit') }

  before do
    sign_in user
  end

  describe 'basic content' do
    it 'renders the title, text, and caption' do
      visit spotlight.edit_exhibit_home_page_path(exhibit)

      add_widget 'mirador'

      page.all('input[name="heading"]').first.set('The Heading')
      page.all('textarea[name="text"]').first.set('The Text')
      page.all('input[name="caption"]').first.set('The Caption')

      save_page

      expect(page).to have_content 'The Heading'
      expect(page).to have_content 'The Text'
      expect(page).to have_content 'The Caption'
    end
  end

  describe 'adding items for the Mirador viewer' do
    describe 'from IIIF' do
      before do
        MockManifestEndpoint.configure do |config|
          config.content = stubbed_manifest('MSS_Barb.gr.252.json')
        end
      end

      it 'adds items via the text input (persisting the title, thumb, and manifest to hidden inputs)' do
        visit spotlight.edit_exhibit_home_page_path(exhibit)

        add_widget 'mirador'
        choose 'IIIF manifest'
        input = find('[data-behavior="source-location-input"]', visible: true)
        expect(input['placeholder']).to eq 'Enter a IIIF manifest URL...'
        input.set('/mock_manifest')
        click_link 'Load IIIF item'

        hidden_title = find('input[type="hidden"][name="items[item_0][title]"]', visible: false)
        hidden_thumb = find('input[type="hidden"][name="items[item_0][thumbnail]"]', visible: false)
        hidden_manifest = find('input[type="hidden"][name="items[item_0][iiif_manifest_url]"]', visible: false)

        expect(hidden_title['value']).to eq 'Barb.gr.252'
        expect(hidden_thumb['value']).to eq(
          'https://digi.vatlib.it/pub/digit/MSS_Barb.gr.252/thumb/Barb.gr.252_0001_al_piatto.anteriore.tif.jpg'
        )
        expect(hidden_manifest['value']).to eq 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json'
      end

      it 'clicking the remove link removes panels' do
        visit spotlight.edit_exhibit_home_page_path(exhibit)

        add_widget 'mirador'
        choose 'IIIF manifest'
        input = find('[data-behavior="source-location-input"]', visible: true)
        input.set('/mock_manifest')
        click_link 'Load IIIF item'

        within '.panels' do
          expect(page).to have_css('.panel-title', text: 'Barb.gr.252')

          click_link 'Remove'

          expect(page).not_to have_css('.panel-title', text: 'Barb.gr.252')
        end
      end
    end
    describe 'from Exhibit' do
      it 'adds items via the autocomplete input (persisting the title, thumb, and manifest to hidden inputs)' do
        visit spotlight.edit_exhibit_home_page_path(exhibit)

        add_widget 'mirador'

        fill_in_solr_document_block_typeahead_field with: 'MSS_Vat_gr_504'
        within(:css, '.panel') do
          expect(page).to have_content 'S. Maximi confessoris opera complura et alia nonnulla'
        end

        hidden_title = find('input[type="hidden"][name="items[item_0][title]"]', visible: false)
        hidden_thumb = find('input[type="hidden"][name="items[item_0][thumbnail]"]', visible: false)
        hidden_manifest = find('input[type="hidden"][name="items[item_0][iiif_manifest_url]"]', visible: false)

        expect(hidden_title['value']).to eq 'S. Maximi confessoris opera complura et alia nonnulla'
        expect(hidden_thumb['value']).to eq(
          'https://digi.vatlib.it/pub/digit/MSS_Vat.gr.504/thumb/Vat.gr.504_0001_al_piatto.anteriore.tif.jpg'
        )
        expect(hidden_manifest['value']).to eq 'https://digi.vatlib.it/iiif/MSS_Vat.gr.504/manifest.json'
      end

      it 'clicking the remove link removes panels' do
        visit spotlight.edit_exhibit_home_page_path(exhibit)

        add_widget 'mirador'

        fill_in_solr_document_block_typeahead_field with: 'MSS_Vat_gr_504'
        within(:css, '.panel') do
          expect(page).to have_content 'S. Maximi confessoris opera complura et alia nonnulla'
        end

        within '.panels' do
          expect(page).to have_css('.panel-title', text: 'S. Maximi confessoris opera complura et alia nonnulla')

          click_link 'Remove'

          expect(page).not_to have_css('.panel-title', text: 'S. Maximi confessoris opera complura et alia nonnulla')
        end
      end
    end
  end

  describe 'mirador config' do
    let(:mirador_config) do
      {
        language: 'en',
        data: [
          {
            manifestUri: 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json'
          }
        ],
        layout: '1x1',
        windowObjects: [
          {
            loadedManifest: 'https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json',
            viewType: 'ImageView'
          }
        ]
      }.to_json
    end

    before do
      MockManifestEndpoint.configure do |config|
        config.content = stubbed_manifest('MSS_Barb.gr.252.json')
      end
    end
    it 'renders a usable Mirador configuration' do
      visit spotlight.edit_exhibit_home_page_path(exhibit)

      add_widget 'mirador'

      choose 'IIIF manifest'
      input = find('[data-behavior="source-location-input"]', visible: true)
      input.set('/mock_manifest')
      click_link 'Load IIIF item'
      hidden_input = find('[name="mirador_config"]', visible: false)

      expect(hidden_input['value']).to eq mirador_config
    end
  end
end
