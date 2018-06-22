##
# Custom Canvas for indexing Annotot::Annotations
class VaticanCanvasBuilder < Spotlight::SolrDocumentBuilder
  include ActiveSupport::Benchmarkable
  delegate :logger, to: :Rails
  delegate :resources, to: :resource
  delegate :size, to: :resources

  def to_solr
    return to_enum(:to_solr) { size } unless block_given?

    benchmark "Indexing resource #{inspect}" do
      base_doc = super
      doc = convert_id(traject_indexer.map_record(resource))
      yield base_doc.merge(doc) if doc
    end
  end

  def traject_indexer
    @traject_indexer ||= Traject::Indexer.new('exhibit_slug' => resource.exhibit.slug).tap do |i|
      i.load_config_file('lib/traject/canvas_config.rb')
    end
  end

  private

  def convert_id(doc)
    doc[:id] = doc['id'].try(:first)
    doc
  end
end
