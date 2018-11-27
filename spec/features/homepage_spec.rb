require 'rails_helper'

RSpec.describe 'Homepage', type: :feature do
  it 'has custom more information links' do
    visit '/'
    expect(page).to have_link 'Vatican library'
    expect(page).to have_link 'DigiVatLib'
    expect(page).to have_link 'Online catalog'
  end
end
