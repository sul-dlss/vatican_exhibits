require 'rails_helper'

RSpec.describe 'Mirador Viewer', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  it 'has an embedded Mirador iframe' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'MSS_Vat_gr_504')
    expect(page).to have_css 'iframe[src*=mirador]'
  end

  context 'when on an edit page' do
    it 'does not have an embedded Mirador iframe' do
      visit spotlight.edit_exhibit_solr_document_path(exhibit, 'MSS_Vat_gr_504')
      expect(page).not_to have_css 'iframe[src*=mirador]'
    end
  end
end
