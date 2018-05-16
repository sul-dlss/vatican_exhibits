require_relative 'vatican_iiif_reader'
require 'traject_plus/macros'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

settings do
  provide 'reader_class_name', 'VaticanIiifReader'
  provide 'processing_thread_pool', 1
end

to_field 'id', (accumulate do |resource, *_|
  resource
    .sub('https://digi.vatlib.it/iiif/', '')
    .sub('/manifest.json', '')
    .tr('.', '_') # TODO: Figure out what we want our ids to be
end)

to_field 'iiif_manifest_url_ssi', (accumulate { |resource, *_| resource })
