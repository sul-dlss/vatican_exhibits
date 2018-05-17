##
# Class used to build / harvest / index for Vatican IIIF resources
class VaticanIiifBuilder < Spotlight::SolrDocumentBuilder
  include ActiveSupport::Benchmarkable
  delegate :logger, to: :Rails
  delegate :resources, to: :resource
  delegate :size, to: :resources

  def to_solr
    return to_enum(:to_solr) { size } unless block_given?

    benchmark "Indexing resource #{inspect}" do
      base_doc = super

      resources.each_with_index do |res, _idx|
        doc = convert_id(traject_indexer.map_record(res))
        yield base_doc.merge(doc) if doc
      end
    end
  end

  def traject_indexer
    @traject_indexer ||= Traject::Indexer.new('exhibit_slug' => resource.exhibit.slug).tap do |i|
      i.load_config_file('lib/traject/vatican_iiif_config.rb')
    end
  end

  private

  ##
  # Needed because traject has a stringed key, but we need a symbol one
  def convert_id(doc)
    doc[:id] = doc['id'].try(:first)
    doc
  end
end
