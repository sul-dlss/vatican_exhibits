##
# Resource used for modeling Annotation content
class AnnotationResource < Spotlight::Resource
  self.document_builder_class = AnnotationBuilder

  store :data, accessors: [:annotations]

  def resources
    return to_enum(:resources) { annotations.size } unless block_given?

    annotations.each do |id|
      annotation = lookup_annotation(id)
      next unless annotation

      yield annotation
    end
  end

  def lookup_annotation(id)
    GlobalID::Locator.locate(id)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("#{id} not found")
    nil
  end

  def delete_from_index
    resources.each do |resource|
      blacklight_solr.delete_by_query "id:#{resource.uuid}"
    end
  end
end
