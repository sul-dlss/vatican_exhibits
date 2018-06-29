##
# Global Spotlight helpers
module SpotlightHelper
  include ::BlacklightHelper
  include Spotlight::MainAppHelpers

  def render_annotation_text_field(value:, **_args)
    safe_join(Array(value).map do |v|
      sanitize v, tags: %w[strong em p]
    end, '')
  end
end
