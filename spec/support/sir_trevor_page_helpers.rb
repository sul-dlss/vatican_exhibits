## These methods are taken from Spotlght to help add sir-trevor widgets
module SirTrevorPageHelpers
  def fill_in_typeahead_field(opts = {})
    type = opts[:type] || 'twitter'
    # Poltergeist / Capybara doesn't fire the events typeahead.js
    # is listening for, so we help it out a little:
    page.execute_script <<-SCRIPT
      $("[data-#{type}-typeahead]:visible").val("#{opts[:with]}").trigger("input");
      $("[data-#{type}-typeahead]:visible").typeahead("open");
      $(".tt-suggestion").click();
    SCRIPT

    find('.tt-suggestion', text: opts[:with], match: :first).click
  end

  # just like #fill_in_typeahead_field, but wait for the
  # form fields to show up on the page too
  def fill_in_solr_document_block_typeahead_field(opts)
    fill_in_typeahead_field(opts)
    expect(page).to have_css("li[data-resource-id=\"#{opts[:with]}\"]")
  end

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
