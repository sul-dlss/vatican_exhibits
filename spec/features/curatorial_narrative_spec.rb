require 'rails_helper'

RSpec.describe 'Curatorial Narratives', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    field = exhibit.custom_fields.find_or_create_by(field: Settings.curatorial_narrative.field)

    doc = SolrDocument.new(id: 'MSS_Vat_gr_504')
    doc.sidecar(exhibit).update(data: { field.field => 'This is a curatorial narrative' })
    doc.reindex
  end

  it 'has a separate column for the curatorial narrative' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'MSS_Vat_gr_504')
    within '.curatorial_narrative' do
      expect(page).to have_css 'h2', text: 'Curatorial narrative'
      expect(page).to have_text 'This is a curatorial narrative'
    end
  end
end
