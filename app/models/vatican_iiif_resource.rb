##
# Resource used for modeling Vatican IIIF content
class VaticanIiifResource < Spotlight::Resource
  self.document_builder_class = VaticanIiifBuilder

  store :data, accessors: [:iiif_url_list]

  class << self
    def instance(current_exhibit)
      find_or_initialize_by exhibit: current_exhibit
    end
  end

  def resources
    return to_enum(:resources) { iiif_urls.size } unless block_given?

    iiif_urls.each { |u| yield u }
  end

  def iiif_urls
    @iiif_urls ||= iiif_url_list.split(/\s+/).reject(&:blank?).uniq
  end

  def size
    iiif_urls.count
  end
end
