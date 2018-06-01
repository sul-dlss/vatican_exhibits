##
# Job that will index related content for a resource
class IndexRelatedContentJob < ApplicationJob
  def perform(harvester, resource)
    VaticanCanvasIndexer.new(harvester.exhibit, resource).index_canvases
  end
end
