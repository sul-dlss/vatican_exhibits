require 'rails_helper'

RSpec.describe 'Manuscript display', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  it 'has a general information section' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'Vat_gr_504')
    expect(page).to have_css 'h2', text: 'General information'

    within '.general-section' do
      expect(page).to have_css 'dt', text: 'Shelfmark'
      expect(page).to have_css 'dd', text: 'Vat.gr.504'
    end
  end

  it 'has a description section' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'Vat_gr_504')
    expect(page).to have_css 'h2', text: 'Description'

    within '.description-section' do
      expect(page).to have_css 'dt', text: 'Language'
      expect(page).to have_css 'dd', text: 'Greco.'
    end
  end

  it 'has parts' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'Vat_gr_504')
    expect(page).to have_css 'h2', text: 'Parts of this manuscript'
    expect(page).to have_css 'h3', text: '1r-4v'
    expect(page).to have_css 'h3', text: '5r-10r'
    expect(page).to have_css 'dt', text: 'Author'
    expect(page).to have_css 'dd', text: 'Gregorius Nazianzenu'
  end
end
