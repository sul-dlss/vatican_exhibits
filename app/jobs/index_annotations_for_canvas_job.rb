# Index an annotot annotation into solr, associated with the correct exhibit
class IndexAnnotationsForCanvasJob < ApplicationJob
  def perform(canvas_id)
    Annotot::Annotation.where(canvas: canvas_id).find_each do |a|
      IndexAnnotationJob.perform_later(a)
    end
  end
end
