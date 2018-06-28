# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  include Spotlight::SolrDocument

  include Spotlight::SolrDocument::AtomicUpdates
  include ManifestConcern


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  module TeiDocument
    def self.extended(document)
      document.will_export_as(:tei, 'application/tei+xml')
    end

    def export_as_tei
      self[:tei_ss]
    end
  end

  use_extension(TeiDocument) do |document|
    document.has? :tei_ss
  end

  def parts
    return to_enum(:parts) unless block_given?

    fetch('parts_ssm', []).each do |value|
      yield SolrDocument.new(JSON.parse(value))
    end
  end
end
