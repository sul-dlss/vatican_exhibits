require 'traject_plus/macros'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

settings do
  provide 'processing_thread_pool', 1
end

each_record do |record, context|
  context.clipboard[:annotation] = ::JSON.parse(record.data)
  context.clipboard[:canvas] = ::JSON.parse(Faraday.get(record.canvas).body)
  context.clipboard[:manifest] = ::JSON.parse(Faraday.get(context.clipboard[:annotation]['on'].first['within']['@id']).body)
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
  to_field 'annotation_tags_ssim', (accumulate do |resource, *_|
    resource['resource'].select { |r| r['@type'] == 'oa:Tag' }.map do |res|
      res['chars'].to_s
    end
  end)
  to_field 'annotation_tags_facet_ssim', (accumulate do |_resource, context|
    context.output_hash['annotation_tags_ssim'].flat_map do |value|
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
    resource['images'].first['resource']['service']['@id']
  end)
end

compose ->(_record, accumulator, context) { accumulator << context.clipboard[:manifest] } do
  extend TrajectPlus::Macros
  to_field 'iiif_manifest_ssi', (accumulate do |resource, *_|
    resource['@id']
  end)
  to_field 'iiif_manifest_label_ssi', (accumulate do |resource, *_|
    resource['label']
  end)
end

to_field 'full_title_tesim', (accumulate do |_resource, context|
  text = context.output_hash['annotation_text_tesim'].join(' ')
  snippet = ActionView::Base.full_sanitizer.sanitize(text).split(/\s+/)[0..3].join(' ')
  "#{context.clipboard[:canvas]['label']}: #{context.clipboard[:manifest]['label']} — #{snippet}"
end)

to_field 'thumbnail_url_ssm', (accumulate do |_resource, context|
  image = context.clipboard[:canvas]['images'].first['resource']['service']['@id']
  selector = context.clipboard[:annotation]['on'].first['selector']['default']
  region = selector['value'].sub('xywh=', '') if selector['@type'] == 'oa:FragmentSelector'
  region ||= 'full'
  "#{image}/#{region}/100,/0/default.jpg"
end)
