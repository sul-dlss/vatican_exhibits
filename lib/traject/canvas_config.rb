require 'traject_plus/macros'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

settings do
  provide 'processing_thread_pool', 1
end

to_field 'id', (accumulate { |resource, *_| "canvas-#{Digest::MD5.hexdigest(resource.url.to_s)}" })

to_field 'full_title_tesim', (accumulate do |resource, *_|
  resource.label
end)

to_field 'annotation_tags_ssim' do |resource, accumulator, _context|
  resource.parsed_annotations.each do |parsed_annotation|
    parsed_annotation['resource'].select { |r| r['@type'] == 'oa:Tag' }.map do |res|
      accumulator << res['chars'].to_s
    end
  end
end
