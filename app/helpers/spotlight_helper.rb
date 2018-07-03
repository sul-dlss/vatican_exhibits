##
# Global Spotlight helpers
module SpotlightHelper
  include ::BlacklightHelper
  include Spotlight::MainAppHelpers

  def render_minimally_styled_narrative_field(value:, **_args)
    safe_join(Array(value).map do |v|
      sanitize v, tags: %w[strong em p a], attributes: %w[href]
    end, '')
  end

  def link_to_manuscript(value:, **_args)
    safe_join(Array(value).map do |v|
      link_to v, spotlight.exhibit_solr_document_path(current_exhibit, v.tr('.', '_'))
    end, '')
  end
end
