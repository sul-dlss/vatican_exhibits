require 'traject_plus/macros'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

settings do
  provide 'processing_thread_pool', 1
end

each_record do |record, context|
  context.skip!("Skipping #{record} because it is not valid") unless record.valid?
end

to_field 'id', (accumulate { |resource, *_| resource.slug })

to_field 'full_title_tesim', (accumulate do |resource, *_|
  (resource.manifest['metadata'].select { |k| k['label'] == 'Title' }.first || {})['value']
end)

to_field 'watermark_tesim' do |resource, accumulator, _context|
  resource.tei.xpath('//watermarks').map do |element|
    accumulator << element.text.strip
  end
end

to_field 'colophon_tesim' do |resource, accumulator, _context|
  resource.tei.xpath('//colophon').map do |element|
    accumulator << element.text.strip
  end
end

to_field 'iiif_manifest_url_ssi', (accumulate { |resource, *_| resource.id })
