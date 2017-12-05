# frozen_string_literal: true

# transforms Vatican TEI into solr documents
class VaticanTeiResourceBuilder < Spotlight::SolrDocumentBuilder
  ##
  # Generate solr documents for the resource
  #
  # @return [Enumerator] an enumerator of solr document hashes for indexing
  def to_solr
    base_doc = super
    doc = traject_indexer.map_record(resource).symbolize_keys
    doc[:id] = Array(doc[:id]).first
    base_doc.merge(doc)
  end

  private

  def traject_indexer
    @traject_indexer ||= Traject::Indexer.new({}).tap do |i|
      i.load_config_file('lib/traject/vatican_tei_config.rb')
    end
  end
end
