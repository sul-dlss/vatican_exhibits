require 'rails_helper'

RSpec.describe 'Annotation display', type: :feature do
  let(:exhibit) { FactoryBot.create(:exhibit) }
  let(:related_annotations) do
    FactoryBot.create(:annotation, canvas: 'https://digi.vatlib.it/iiif/MSS_Urb.lat.491/canvas/p0012', data: {
      resource: [{
        '@type' => 'oa:Something',
        'chars' => 'some data'
      }]
    }.to_json)
    FactoryBot.create(:annotation, canvas: 'https://digi.vatlib.it/iiif/MSS_Urb.lat.491/canvas/p0012', data: {
      resource: [{
        '@type' => 'oa:Tag',
        'chars' => 'tags are ignored'
      }]
    }.to_json)
  end

  it 'has a viewer' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'ad73da4e-0072-4b07-a12c-a8d10ac2a9ab')
    expect(page).to have_css 'iframe[src*=mirador]'
  end

  it 'has some metadata' do
    visit spotlight.exhibit_solr_document_path(exhibit, 'ad73da4e-0072-4b07-a12c-a8d10ac2a9ab')
    expect(page).to have_css 'dt', text: 'Annotation text'
    expect(page).to have_css 'dd', text: /particolare dell'esercito/
  end

  it 'has related annotations' do
    related_annotations

    visit spotlight.exhibit_solr_document_path(exhibit, 'ad73da4e-0072-4b07-a12c-a8d10ac2a9ab')
    expect(page).to have_css 'li', text: 'some data'
    expect(page).not_to have_css 'li', text: 'tags are ignored'
  end
end
