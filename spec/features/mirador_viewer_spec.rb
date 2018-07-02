require 'rails_helper'

RSpec.describe 'Mirador Viewer', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  it 'has an embedded Mirador iframe' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'Vat_gr_504')
    expect(page).to have_css 'iframe[src*=mirador]'
    expect(page).not_to have_css 'iframe[src*=canvas]'
  end

  context 'when on an edit page' do
    it 'does not have an embedded Mirador iframe' do
      visit spotlight.edit_exhibit_solr_document_path(exhibit, 'MSS_Vat_gr_504')
      expect(page).not_to have_css 'iframe[src*=mirador]'
    end
  end

  context 'when on an annotation page' do
    it 'requests a mirador viewer with a canvas parameter' do
      visit spotlight.exhibit_solr_document_path(exhibit, 'ad73da4e-0072-4b07-a12c-a8d10ac2a9ab')
      expect(page).to have_css 'iframe[src*=canvas\=https\%3A\%2F\%2Fdigi\.vat'\
        'lib\.it\%2Fiiif\%2FMSS_Urb\.lat\.491\%2Fcanvas\%2Fp0012]'
    end
  end
end
