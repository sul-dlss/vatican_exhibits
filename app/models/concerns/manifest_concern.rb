# SolrDocument helper methods for IIIF Manifests
module ManifestConcern
  ##
  # Return a document's manifest url
  def manifest
    fetch('iiif_manifest_url_ssi', nil)
  end
end
