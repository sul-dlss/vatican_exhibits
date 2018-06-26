##
# Harvester used for retrieving IIIF manifests from Vatican resources
class IiifHarvester
  attr_reader :iiif_manifest_url

  ##
  # @param [String] iiif_manifest_url
  def initialize(iiif_manifest_url)
    @iiif_manifest_url = iiif_manifest_url
  end

  def valid?
    manifest.present?
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

  def tei_url
    tei_template_url.gsub('{shelfmark}', shelfmark.sub('MSS_', ''))
  end

  def thumbnails
    return [] if manifest['sequences'].blank?

    manifest['sequences'].flat_map do |sequence|
      next [] if sequence['canvases'].blank?

      sequence['canvases'].map do |canvas|
        canvas.dig('thumbnail', '@id')
      end.compact
    end
  end

  def tei
    @tei ||= begin
      Nokogiri::XML(Rails.cache.fetch(tei_url) do
        Faraday.get(tei_url).body
      end)
    rescue Faraday::Error => e
      Rails.logger.warn("#{self.class.name} failed to fetch #{tei_url} with: #{e}")
      '{}'
    end
  end

  def response
    @response ||= begin
      Rails.cache.fetch(iiif_manifest_url) do
        Faraday.get(iiif_manifest_url).body
      end
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

  def tei_template_url
    Settings.vatican_iiif_resource.tei_template_url
  end
end
