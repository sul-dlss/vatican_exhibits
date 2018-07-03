require 'rails_helper'

RSpec.describe SpotlightHelper, type: :helper do
  describe '#render_minimally_styled_narrative_field' do
    let(:value) do
      <<-EOHTML
      <p><span style="font-size: 12.0pt; line-height: 115%; font-family: 'Calibri',sans-serif; mso-ascii-theme-font: minor-latin; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-hansi-theme-font: minor-latin; mso-bidi-theme-font: minor-latin; mso-ansi-language: IT; mso-fareast-language: EN-US; mso-bidi-language: AR-SA;">La <em>r</em> e la <em>s</em> hanno forme molto simili con l&rsquo;unica differenza che, mentre la <em>r</em> ripiega bruscamente in forma angolosa, la <em>s</em> ha una forma pi&ugrave; tondeggiante.</span></p>
      EOHTML
    end

    it 'allows a minimal set of safe(r) HTML to be displayed' do
      result = render_minimally_styled_narrative_field(value: value)
      expect(result).to be_html_safe
      expect(result).not_to match(/style/)
    end
  end

  describe '#link_to_manuscript' do
    let(:exhibit) { FactoryBot.build_stubbed(:exhibit) }

    before do
      helper.send(:extend, Module.new { def current_exhibit; end })
      allow(helper).to receive_messages(current_exhibit: exhibit)
    end

    it 'creates a link to the manuscript show page' do
      result = helper.link_to_manuscript(value: 'Vat.gr.1')
      expect(result).to eq link_to 'Vat.gr.1', '/1001/catalog/Vat_gr_1'
    end
  end
end
