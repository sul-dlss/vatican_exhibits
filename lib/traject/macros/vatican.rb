module Macros
  ##
  # Module for Vatican Resource specific macros
  module Vatican
    def vatican_tei(xpath, options = {})
      lambda do |resource, accumulator, _context|
        result = resource.tei.xpath(xpath).map(&:text)
        result = TrajectPlus::Extraction.apply_extraction_options(result, options)
        accumulator.concat(result)
      end
    end
  end
end
