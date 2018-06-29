require 'rails_helper'

RSpec.describe SpotlightHelper, type: :helper do
  describe '#render_annotation_text_field' do
    let(:value) do
      <<-EOHTML
      <p><span style="font-size: 12.0pt; line-height: 115%; font-family: 'Calibri',sans-serif; mso-ascii-theme-font: minor-latin; mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-hansi-theme-font: minor-latin; mso-bidi-theme-font: minor-latin; mso-ansi-language: IT; mso-fareast-language: EN-US; mso-bidi-language: AR-SA;">La <em>r</em> e la <em>s</em> hanno forme molto simili con l&rsquo;unica differenza che, mentre la <em>r</em> ripiega bruscamente in forma angolosa, la <em>s</em> ha una forma pi&ugrave; tondeggiante.</span></p>
      EOHTML
    end

    it 'cleans up annotation text' do
      result = render_annotation_text_field(value: value)
      expect(result).to be_html_safe
      expect(result).not_to match(/style/)
    end
  end
end
