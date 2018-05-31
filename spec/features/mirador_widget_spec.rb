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

      page.all('input[name="heading"]').first.set('The Heading')
      page.all('textarea[name="text"]').first.set('The Text')
      page.all('input[name="caption"]').first.set('The Caption')

      save_page

      expect(page).to have_content 'The Heading'
      expect(page).to have_content 'The Text'
      expect(page).to have_content 'The Caption'
    end
  end
end
