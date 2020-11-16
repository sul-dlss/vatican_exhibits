require 'traject_plus/macros'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

settings do
  provide 'processing_thread_pool', 1
end

each_record do |record, context|
  context.skip!("Skipping #{record} because it is not present") unless record
  context.clipboard[:annotation] = ::JSON.parse(record.data)

  manifest_url = AnnotationCompatibility.new(context.clipboard[:annotation]).manifest_uri
  manifest_body = Rails.cache.fetch(manifest_url) do
    Faraday.get(manifest_url).body
  end
  context.clipboard[:manifest] = ::JSON.parse(manifest_body)

  context.clipboard[:canvas] = context.clipboard[:manifest]['sequences'][0]['canvases'].find do |canvas|
    canvas['@id'] == record.canvas
  end

  context.clipboard[:structures] = Array(context.clipboard[:manifest]['structures']).select do |structure|
    Array(structure['canvases']).include? record.canvas
  end
end

to_field 'id', (accumulate { |resource, *_| resource.uuid })
to_field 'canvas_ssi', (accumulate { |resource, *_| resource.canvas })
to_field 'resource_type_ssim', literal('Annotation')

compose ->(_record, accumulator, context) { accumulator << context.clipboard[:annotation] } do
  extend TrajectPlus::Macros
  to_field 'type_ssi', (accumulate do |resource, *_|
    resource['@type']
  end)
  to_field 'motivation_ssim', (accumulate do |resource, *_|
    resource['motivation']
  end)
  to_field 'annotation_text_tesim', (accumulate do |resource, *_|
    resource['resource'].reject { |r| r['@type'] == 'oa:Tag' }.map do |res|
      res['chars'].to_s
    end
  end)
  to_field 'annotation_tags_it_ssim', (accumulate do |resource, *_|
    resource['resource'].select { |r| r['@type'] == 'oa:Tag' }.map do |res|
      res['chars'].to_s
    end
  end)
  to_field 'annotation_tags_facet_it_ssim', (accumulate do |_resource, context|
    Array(context.output_hash['annotation_tags_it_ssim']).flat_map do |value|
      case value
      when /\(.+\)/
        components = value.match(/^(.*)\((.+)\)/).captures.map(&:strip)

        [components.first, components.join(':')]
      else
        value
      end
    end
  end)
  to_field 'annotation_tags_en_ssim', extract: (accumulate { |_, context| context.output_hash['annotation_tags_it_ssim'] }),
                                      transform: transform(translation_map: 'annotation_tags')

  to_field 'annotation_tags_facet_en_ssim', (accumulate do |_resource, context|
    Array(context.output_hash['annotation_tags_en_ssim']).flat_map do |value|
      case value
      when /\(.+\)/
        components = value.match(/^(.*)\((.+)\)/).captures.map(&:strip)

        [components.first, components.join(':')]
      else
        value
      end
    end
  end)
end

compose ->(_record, accumulator, context) { accumulator << context.clipboard[:canvas] } do
  extend TrajectPlus::Macros
  to_field 'canvas_label_ssi', (accumulate do |resource, *_|
    resource['label']
  end)
  to_field 'canvas_thumbnail_ssi', (accumulate do |resource, *_|
    resource['thumbnail']['@id']
  end)
  to_field 'iiif_image_resource_ssi', (accumulate do |resource, *_|
    resource['images'].first.dig('resource', 'service', '@id')
  end)
end

compose ->(_record, accumulator, context) { accumulator << context.clipboard[:manifest] } do
  extend TrajectPlus::Macros
  to_field 'manuscript_shelfmark_ssim', (accumulate do |resource, *_|
    IiifHarvester.new(resource['@id']).shelfmark
  end)
  to_field 'iiif_manifest_url_ssi', (accumulate do |resource, *_|
    resource['@id']
  end)
  to_field 'iiif_manifest_label_ssi', (accumulate do |resource, *_|
    resource['label']
  end)
end

compose ->(_record, accumulator, context) { accumulator.concat(context.clipboard[:structures]) } do
  extend TrajectPlus::Macros
  to_field 'iiif_structure_label_ssim', (accumulate do |resource, *_|
    CGI.unescapeHTML(resource['label'])
  end)

  to_field 'iiif_structure_id_ssim', (accumulate do |resource, *_|
    resource['@id']
  end)
end

to_field 'full_title_tesim', (accumulate do |_resource, context|
  text = Array(context.output_hash['annotation_text_tesim']).join(' ')
  snippet = ActionView::Base.full_sanitizer.sanitize(text).split(/\s+/)[0..3].join(' ')
  "#{context.clipboard[:canvas]['label']}: #{context.clipboard[:manifest]['label']} — #{snippet}"
end)

to_field 'thumbnail_url_ssm', (accumulate do |_resource, context|
  thumb_size = '100,'
  image_resource = context.clipboard[:canvas]['images'].first.dig('resource', 'service', '@id')
  if image_resource
    selector = AnnotationCompatibility.new(context.clipboard[:annotation]).selector
    region = selector['value'].sub('xywh=', '') if selector['@type'] == 'oa:FragmentSelector'
    region ||= 'full'
    "#{image_resource}/#{region}/#{thumb_size}/0/default.jpg"
  else
    # Case where there is no image resource. Usually a "full" rotated for a "rotation" manifest
    thumb_url = context.clipboard[:canvas]['thumbnail']['@id']
    thumb_url.gsub('/,150/', "/#{thumb_size}/") if %r(/\d*/[a-z]*\.[a-z]{3,4}$).match?(thumb_url) # /123/native.jpg|wbp
  end
end)
