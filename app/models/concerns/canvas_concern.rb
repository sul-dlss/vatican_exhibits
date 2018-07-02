# SolrDocument helper methods for IIIF Canvases
module CanvasConcern
  ##
  # Return a document's canvas ID
  def canvas
    fetch('canvas_ssi', nil)
  end
end
