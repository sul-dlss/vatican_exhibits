# Index an annotot annotation into solr, associated with the correct exhibit
class IndexAnnotationJob < ApplicationJob
  discard_on ActiveJob::DeserializationError do |_job, error|
    Rails.logger.error("Skipping job because of ActiveJob::DeserializationError (#{error.message})")
  end

  def perform(annotation)
    if annotation.destroyed?
      destroy(annotation)
    else
      index(annotation)
    end
  end

  private

  def index(annotation)
    VaticanIiifResource.find_each do |resource|
      next unless resource.iiif_urls.include? manifest_uri(annotation)

      AnnotationResource.new(exhibit: resource.exhibit, annotations: [annotation.to_global_id]).reindex
    end
  end

  def destroy(annotation)
    AnnotationResource.new(exhibit: nil, annotations: [annotation.to_global_id]).delete_from_index
  end

  def manifest_uri(annotation)
    AnnotationCompatibility.new(JSON.parse(annotation.data)).manifest_uri
  end
end
