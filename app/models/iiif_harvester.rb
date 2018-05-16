##
# Harvester used for retrieving IIIF manifests from Vatican resources
class IiifHarvester
  attr_reader :iiif_manifest_url
  ##
  # @param [String] iiif_manifest_url
  def initialize(iiif_manifest_url)
    @iiif_manifest_url = iiif_manifest_url
  end

  def id
    manifest['@id']
  end

  def shelfmark
    id
      .sub('https://digi.vatlib.it/iiif/', '')
      .sub('/manifest.json', '')
  end

  def slug
    shelfmark
      .tr('.', '_') # TODO: Figure out what we want our ids to be; see https://github.com/sul-dlss/vatican_exhibits/issues/37
  end

  def response
    @response ||= begin
      Faraday.get(iiif_manifest_url).body
    rescue Faraday::Error => e
      Rails.logger.warn("#{self.class.name} failed to fetch #{iiif_manifest_url} with: #{e}")
      '{}'
    end
  end

  def manifest
    @manifest ||= begin
      JSON.parse(response)
    rescue JSON::ParserError => e
      Rails.logger.warn("#{self.class.name} failed to parse #{iiif_manifest_url} with: #{e}")
      {}
    end
  end
end
