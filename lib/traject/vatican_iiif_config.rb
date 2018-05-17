require 'traject_plus/macros'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

settings do
  provide 'processing_thread_pool', 1
end

to_field 'id', (accumulate { |resource, *_| resource.slug })

to_field 'full_title_tesim', (accumulate do |resource, *_|
  resource.manifest['metadata'].select { |k| k['label'] == 'Title' }.first['value']
end)

to_field 'iiif_manifest_url_ssi', (accumulate { |resource, *_| resource.id })
