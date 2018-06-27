require 'rails_helper'

RSpec.describe 'Manuscript parts display', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  it 'has parts' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'MSS_Vat_gr_504')
    expect(page).to have_css 'h2', text: 'Parts of this manuscript'
    expect(page).to have_css 'h3', text: '1r-4v'
    expect(page).to have_css 'h3', text: '5r-10r'
    expect(page).to have_css 'dt', text: 'Author'
    expect(page).to have_css 'dd', text: 'Gregorius Nazianzenu'
  end
end
