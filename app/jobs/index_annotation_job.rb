# Index an annotot annotation into solr, associated with the correct exhibit
class IndexAnnotationJob < ApplicationJob
  def perform(annotation)
    if annotation.destroyed?
      destroy(annotation)
    else
      index(annotation)
    end
  end

  private

  def index(annotation)
    manifest_uri = JSON.parse(annotation.data)['on'].first['within']['@id']

    VaticanIiifResource.find_each do |resource|
      next unless resource.iiif_urls.include? manifest_uri

      AnnotationResource.new(exhibit: resource.exhibit, annotations: [annotation.to_global_id]).reindex
    end
  end

  def destroy(annotation)
    AnnotationResource.new(exhibit: nil, annotations: [annotation.to_global_id]).delete_from_index
  end
end
