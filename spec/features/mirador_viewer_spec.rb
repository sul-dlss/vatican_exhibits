require 'rails_helper'

RSpec.describe 'Mirador Viewer', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  it 'has an embedded Mirador iframe' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'MSS_Vat_gr_504')
    expect(page).to have_css 'iframe[src*=mirador]'
  end
end
