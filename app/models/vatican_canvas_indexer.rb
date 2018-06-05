##
# Index the annotations for canvases in a given IiifHarvester
class VaticanCanvasIndexer
  attr_reader :exhibit, :resource

  delegate :manifest, to: :manifest_harvester

  def initialize(exhibit, iiif_manifest_url)
    @exhibit = exhibit
    @resource = IiifHarvester.new(iiif_manifest_url)
  end

  def index_canvases
    resource.canvases.each do |canvas|
      annotation_data = Annotot::Annotation.where(canvas: canvas['@id']).pluck(:data)
      next if annotation_data.blank?
      canvas_resource = CanvasResource.find_or_initialize_by(url: canvas['@id'], exhibit: exhibit)
      canvas_resource.annotations = annotation_data
      canvas_resource.label = canvas['label']
      canvas_resource.save_and_index
    end
  end

  private

  def manifest_url
    resource.iiif_manifest_url
  end
end
