##
# Job that will index related content for a resource
class IndexRelatedContentJob < ApplicationJob
  def perform(exhibit, resource)
    VaticanCanvasIndexer.new(exhibit, resource).index_canvases
  end
end
