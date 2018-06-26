require 'traject_plus/macros'

# rubocop:disable Style/MixinUsage
extend TrajectPlus::Macros
# rubocop:enable Style/MixinUsage

settings do
  provide 'processing_thread_pool', 1
  provide 'allow_duplicate_values', false
end

each_record do |record, context|
  context.skip!("Skipping #{record} because it is not valid") unless record.valid?
end

to_field 'id', (accumulate { |resource, *_| resource.slug })
to_field 'resource_type_ssim', literal('Manuscript')

to_field 'full_title_tesim', (accumulate do |resource, *_|
  (resource.manifest['metadata'].select { |k| k['label'] == 'Title' }.first || {})['value']
end)

to_field 'watermark_tesim' do |resource, accumulator, _context|
  resource.tei.xpath('//watermarks').map do |element|
    accumulator << element.text.strip
  end
end

to_field 'collection_ssim', (accumulate { |resource, *_| resource.collection })

compose ->(record, accumulator, _context) { accumulator << record.tei.xpath('//TEI.2/teiHeader/fileDesc/sourceDesc/msDescription/msPart/msContents/msItem') } do
  extend TrajectPlus::Macros
  extend TrajectPlus::Macros::Xml

  to_field 'date_ssim', extract_xml(
    'origDate', nil,
    strip: true,
    downcase: true
  )
  to_field 'beginning_date_ssim', extract_xml(
    'origDate/@notBefore', nil
  )
  to_field 'ending_date_ssim', extract_xml(
    'origDate/@notAfter', nil
  )
  to_field 'dated_mss_ssim', extract_xml(
    'origDate/@n', nil
  )

  to_field 'author_ssim', extract_xml(
    "author/alias/authorityAuthor[@rif='aut']", nil,
    gsub: [/[,\.]$/, '']
  )
  to_field 'author_ssim', extract_xml(
    'textLang', nil,
    gsub: [/[,\.]$/, '']
  )
  to_field 'other_author_ssim', extract_xml(
    "name[@role='internal' or @role='external']/alias/authorityAuthor[@rif='aut']", nil,
    gsub: [/[,\.]$/, '']
  )
  to_field 'other_name_ssim', extract_xml(
    "name[@role!='internal' and @role!='external' or not(@role)]/alias/authorityAuthor[@rif='aut']", nil,
    gsub: [/[,\.]$/, '']
  )
  to_field 'place_ssim', extract_xml(
    'origPlace/settlement', nil
  )
  to_field 'language_ssim', extract_xml(
    'textLang', nil,
    strip: true,
    gsub: [/.$/, '']
  )
end

compose ->(record, accumulator, _context) { accumulator << record.tei } do
  extend TrajectPlus::Macros
  extend TrajectPlus::Macros::Xml

  to_field 'author_ssim', extract_xml(
    "//titleStmt/author/alias/authorityAuthor[@rif='aut']/text()", nil,
    gsub: [/[,\.]$/, '']
  )
  to_field 'other_author_ssim', extract_xml(
    "//titleStmt/respStmt/resp/name[@role='internal' or @role='external']/alias/authorityAuthor[@rif='aut']", nil,
    gsub: [/[,\.]$/, '']
  )
end
# TODO: Should we add this here?
# to_field 'other_name_ssim', vatican_tei(
#   "TEI.2/teiHeader/fileDesc/titleStmt/respStmt/resp/name[@role!='internal' and @role!='external' or not(@role)]/alias/authorityAuthor[@rif='aut']"
# )
to_field 'name_ssim', copy('author_ssim')
to_field 'name_ssim', copy('other_author_ssim')
to_field 'name_ssim', copy('other_name_ssim')

to_field 'author_tesim', copy('author_ssim')
to_field 'collection_tesim', copy('collection_ssim')
to_field 'date_tesim', copy('date_ssim')
to_field 'language_tesim', copy('language_ssim')


to_field 'colophon_tesim' do |resource, accumulator, _context|
  resource.tei.xpath('//colophon').map do |element|
    accumulator << element.text.strip
  end
end

to_field 'thumbnail_url_ssm', (accumulate { |resource, *_| resource.thumbnails })

to_field 'iiif_manifest_url_ssi', (accumulate { |resource, *_| resource.id })
