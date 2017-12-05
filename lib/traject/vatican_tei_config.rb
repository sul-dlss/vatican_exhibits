# frozen_string_literal: true

extend TrajectPlus::Macros

settings do
  provide 'reader_class_name', 'TrajectPlus::XmlReader'
end

to_field 'id', (accumulate { |resource, *_| resource.id })
to_field 'teixml_ss', (accumulate { |resource, *_| resource.blob })

compose ->(record, accumulator, _context) { accumulator << record.xml } do
  extend TrajectPlus::Macros
  extend TrajectPlus::Macros::Xml
  extend TrajectPlus::Macros::Tei

  pub_stmt = '/*/tei:teiHeader/tei:fileDesc/tei:publicationStmt'
  to_field 'cho_publisher_ssim', extract_tei("#{pub_stmt}/tei:publisher")
  to_field 'cho_dc_rights_ssim',
           extract: extract_tei("#{pub_stmt}/tei:availability/tei:licence"),
           transform: transform(strip: true)

  ms_desc = '/*/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc'
  ms_id = 'tei:msIdentifier'
  to_field 'cho_identifier_ssim', extract_tei("#{ms_desc}/#{ms_id}/tei:idno[@type='call-number']")
  to_field 'agg_is_shown_at.wr_id_ssim', extract_tei("#{ms_desc}/#{ms_id}/tei:altIdentifier[@type='resource']/tei:idno")
  ms_contents = 'tei:msContents'
  to_field 'cho_description_ssim', extract_tei("#{ms_desc}/#{ms_contents}/tei:summary")
  to_field 'cho_language_ssim', extract_tei("#{ms_desc}/#{ms_contents}/tei:textLang")

  ms_item = 'tei:msItem'
  to_field 'cho_title_ssim', extract_tei("#{ms_desc}/#{ms_contents}/#{ms_item}/tei:title")
  to_field 'cho_creator_ssim', extract_tei("#{ms_desc}/#{ms_contents}/#{ms_item}/tei:author")

  ms_origin = 'tei:history/tei:origin'
  to_field 'cho_date_ssim', extract_tei("#{ms_desc}/#{ms_origin}/tei:origDate")
  to_field 'cho_spatial_ssim', extract_tei("#{ms_desc}/#{ms_origin}/tei:origPlace")
  to_field 'cho_provenance_ssim', extract_tei("#{ms_desc}/tei:history/tei:provenance")

  obj_desc = 'tei:physDesc/tei:objectDesc'
  to_field 'cho_extent_ssim', extract_tei("#{ms_desc}/#{obj_desc}/tei:layoutDesc/tei:layout")

  support_desc = 'tei:supportDesc[@material="paper"]'
  to_field 'cho_extent_ssim', extract_tei("#{ms_desc}/#{obj_desc}/#{support_desc}/tei:extent")

  profile_desc = '/*/tei:teiHeader/tei:profileDesc/tei:textClass'
  to_field 'cho_subject_ssim', extract_tei("#{profile_desc}/tei:keywords[@n='form/genre']/tei:term")
  to_field 'cho_subject_ssim', extract_tei("#{profile_desc}/tei:keywords[@n='subjects']/tei:term")
end
