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

  def collection
    Settings.vatican.collections.select do |collection|
      shelfmark.start_with? collection
    end.max_by(&:length)
  end

  def shelfmark
    id
      .sub(%r{https://digi\.vatlib\.it/(iiif|rotation)/}, '')
      .sub('/manifest.json', '')
      .gsub('MSS_', '')
  end

  def slug
    slug = shelfmark.tr('.', '_')
    slug = "rotation-#{slug}" if id.include? 'rotation'
    slug
  end

  def tei_url
    tei_template_url.gsub('{shelfmark}', shelfmark)
  end

  def thumbnails
    ([thumbnail] + canvas_thumbnails).compact
  end

  def canvas_thumbnails
    canvases.flat_map do |canvas|
      canvas.dig('thumbnail', '@id')
    end.compact
  end

  def thumbnail
    return nil if manifest['thumbnail'].blank?

    manifest['thumbnail']['@id']
  end

  def canvases
    return [] if manifest['sequences'].blank?

    manifest['sequences'].flat_map do |sequence|
      next [] if sequence['canvases'].blank?

      sequence['canvases']
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
