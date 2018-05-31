## These methods are taken from Spotlght to help add sir-trevor widgets
module SirTrevorPageHelpers
  def add_widget(type)
    click_add_widget

    # click the item + image widget
    expect(page).to have_css("button[data-type='#{type}']")
    find("button[data-type='#{type}']").click
  end

  def click_add_widget
    if all('.st-block-replacer').blank?
      expect(page).to have_css('.st-block-addition')
      first('.st-block-addition').click
    end
    expect(page).to have_css('.st-block-replacer')
    first('.st-block-replacer').click
  end

  def save_page
    page.execute_script <<-EOJS
      SirTrevor.getInstance().onFormSubmit();
    EOJS

    click_button('Save changes')

    expect(page).to have_selector('.alert-info', text: 'page was successfully updated')
  end
end
