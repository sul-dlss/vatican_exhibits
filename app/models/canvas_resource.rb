##
# CanvasResource model class
class CanvasResource < Spotlight::Resource
  self.document_builder_class = VaticanCanvasBuilder

  store :data, accessors: [:annotations, :label]

  def resources
    annotations
  end

  def parsed_annotations
    annotations.map { |a| JSON.parse(a) }
  end
end
