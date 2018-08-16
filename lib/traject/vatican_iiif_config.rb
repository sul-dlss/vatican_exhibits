require 'traject_plus/macros'
require 'name_display'

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
to_field 'shelfmark_tsim', (accumulate { |resource, *_| resource.shelfmark })
to_field 'full_title_tesim', copy('shelfmark_tsim')

to_field 'collection_ssim', (accumulate { |resource, *_| resource.collection })

to_field 'tei_ss', (accumulate { |resource, *_| resource.tei.to_s })

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
  to_field 'author_ssim', (accumulate do |resource, *_|
    resource.xpath("author/alias/authorityAuthor[@rif='aut']").map do |author|
      NameDisplay.new(
        author
      ).display
    end
  end)
  to_field 'other_author_ssim', (accumulate do |resource, *_|
    resource.xpath("name[@role='internal' or @role='external']/alias/authorityAuthor[@rif='aut']").map do |author|
      NameDisplay.new(
        author
      ).display
    end
  end)
  to_field 'other_name_ssim', (accumulate do |resource, *_|
    resource.xpath("name[@role!='internal' and @role!='external' or not(@role)]/alias/authorityAuthor[@rif='aut']").map do |author|
      NameDisplay.new(
        author
      ).display
    end
  end)
  to_field 'other_name_and_role_ssim', (accumulate do |resource, *_|
    resource.xpath("name[@role!='internal' and @role!='external' or not(@role)]").flat_map do |name|
      name.xpath("alias/authorityAuthor[@rif='aut']").map do |author|
        author_name = author.text.gsub(/[,\.]$/, '')

        if name['role'].present?
          "#{author_name} [#{name['role']}]"
        else
          author_name
        end
      end
    end
  end)
  to_field 'place_ssim', extract_xml(
    'origPlace/settlement', nil
  )
  to_field 'language_ssim', extract_xml(
    'textLang', nil,
    strip: true,
    gsub: [/.$/, '']
  )
  to_field 'incipit_tesim', extract_xml(
    "incipit[@type='text']/@value", nil
  )
  to_field 'incipit_tesim', extract_xml(
    'incipit[not(@type)]/@value', nil
  )
  to_field 'explicit_tesim', extract_xml(
    "explicit[@type='text']/@value", nil
  )
  to_field 'explicit_tesim', extract_xml(
    'explicit[not(@type)]/@value', nil
  )
  to_field 'title_tesim', extract_xml(
    "title[@type='title']/@value", nil
  )
  to_field 'title_tesim', extract_xml(
    "title[@type='supplied']/@value", nil
  )
  to_field 'title_tesim', extract_xml(
    "uniformTitle/alias/authorityTitleSeries[@rif='aut']/@value", nil
  )
  to_field 'summary_tesim', extract_xml(
    'summary', nil
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
  to_field 'title_tesim', extract_xml(
    "//titleStmt/title[@level!='u' or not(@level)]/@value", nil
  )
  to_field 'overview_tesim', extract_xml(
    '//TEI.2/teiHeader/fileDesc/sourceDesc/msDescription/msPart/msContents/overview/p/@value', nil
  )
  to_field 'all_text_timv', extract_xml(
    '//text()', nil
  )
end

compose ->(record, accumulator, _context) { accumulator << record.tei.xpath('//TEI.2/teiHeader/fileDesc/sourceDesc/msDescription[@n="y"]') } do
  extend TrajectPlus::Macros
  extend TrajectPlus::Macros::Xml

  to_field 'ms_collection_ssim', extract_xml('msIdentifier/collection', nil)	# Fondo	Collection
  to_field 'ms_shelfmark_tesim', extract_xml('msIdentifier/idno', nil) #	Segnatura	Shelfmark
  to_field 'ms_library_tesim', extract_xml('msIdentifier/repository', nil) #	Biblioteca	Library
  to_field 'ms_ocelli_nominum_tesim', extract_xml('msIdentifier/altName', nil) #	Altra denominazione	Ocelli nominum
  to_field 'ms_date_ssim', extract_xml('msPart/msContents/msItem/origDate', nil) #	Datazione	Date
  to_field 'ms_date_mss_ssim', extract_xml('msPart/msContents/msItem/origDate/@n', nil) #		Datato	Dated Mss
  to_field 'ms_beginning_date_tesim', extract_xml('msPart/msContents/msItem/origDate/@notBefore', nil) #		Data inizio	Beginning date
  to_field 'ms_ending_date_tesim', extract_xml('msPart/msContents/msItem/origDate/@notAfter', nil) #		Data fine	Ending date
  to_field 'ms_date_of_text_tesim', extract_xml('msPart/msContents/msItem/origDate/@value', nil) #		Data testo	Date of text
  to_field 'ms_country_ssim', extract_xml('msPart/msContents/msItem/origPlace/country', nil) #	Paese	Country
  to_field 'ms_region_ssim', extract_xml('msPart/msContents/msItem/origPlace/region', nil) #	Regione	Region
  to_field 'ms_place_ssim', extract_xml('msPart/msContents/msItem/origPlace/settlement', nil) #	Localita	Place
  to_field 'ms_support_tesim', extract_xml('msPart/physDesc/support/p', nil) #	Materiale	Support
  to_field 'ms_physical_shapes_tesim', extract_xml('msPart/physDesc/form/p', nil) #	Forma	Physical shapes
  to_field 'ms_height_tesim', extract_xml('msPart/physDesc/dimensions/height', nil) #	Altezza	Height
  to_field 'ms_width_tesim', extract_xml('msPart/physDesc/dimensions/width', nil) #	Larghezza	Width
  to_field 'ms_depth_tesim', extract_xml('msPart/physDesc/dimensions/depth', nil) #	Profondita	Depth
  to_field 'ms_extent_tesim', extract_xml('msPart/physDesc/extent', nil) #	Numero fogli	Extent
  to_field 'ms_content_tesim', extract_xml('msPart/msContents/p', nil) #	Contenuto	Content
  to_field 'ms_overview_tesim', extract_xml('msPart/msContents/overview/p/@value', nil) #		Nota generale	Overview
  to_field 'ms_collation_tesim', extract_xml('msPart/physDesc/collation/p', nil) #	Collazione	Collation
  to_field 'ms_layout_tesim', extract_xml('msPart/physDesc/layout/p', nil) #	Impaginazione	Layout
  to_field 'ms_foliation_tesim', extract_xml('msPart/physDesc/foliation/p', nil) #	Foliazione	Foliation
  to_field 'ms_writing_tesim', extract_xml('msPart/head/scriptTerm', nil) #	Scrittura	Writing
  to_field 'ms_writing_note_tesim', extract_xml('msPart/physDesc/msWriting/p', nil) #	Scrittura - Nota	Writing - Note
  to_field 'ms_music_notation_tesim', extract_xml('msPart/physDesc/musicNotation/p', nil) #	Notazione musicale	Music notation
  to_field 'ms_punctuation_tesim', extract_xml('msPart/physDesc/punctuation/p', nil) #	Punteggiatura	Punctuation
  to_field 'ms_decoration_tesim', extract_xml('msPart/physDesc/decoration/p', nil) #	Decorazione	Decoration
  to_field 'ms_decoration_note_tesim', extract_xml('msPart/physDesc/decoration/decoNote/p', nil) #	Decorazione - Nota	Decoration - Note
  to_field 'ms_binding_tesim', extract_xml('msPart/physDesc/bindingDesc/binding/p', nil) #	Legatura	Binding
  to_field 'ms_binding_note_tesim', extract_xml('msPart/physDesc/bindingDesc/binding/decoNote/p', nil) #	Legatura -Nota	Binding - Note
  to_field 'ms_additions_tesim', extract_xml('msPart/physDesc/additions/p', nil) #	Allegati	Additions
  to_field 'ms_condition_tesim', extract_xml('msPart/physDesc/condition/p', nil) #	Stato di conservazione	Condition
  to_field 'ms_signatures_tesim', extract_xml('msPart/physDesc/signatures', nil) #	Segnature di fascicoli	Signatures
  to_field 'ms_catchwords_tesim', extract_xml('msPart/physDesc/catchwords', nil) #	Verba reclamantia	Catchwords
  to_field 'ms_palimpsest_tesim', extract_xml('msPart/physDesc/palimpsest/p', nil) #	Palinsesto	Palimpsest
  to_field 'ms_physical_description_tesim', extract_xml('msPart/physDesc/p', nil) #	Descrizione fisica	Physical description
  to_field 'ms_heraldry_tesim', extract_xml('msPart/head/heraldry', nil) #	Stemma	Heraldry
  to_field 'ms_seal_tesim', extract_xml('msPart/head/seal', nil) #	Sigillo	Seal
  to_field 'ms_format_tesim', extract_xml('msPart/head/format', nil) #	Formato	Format
  to_field 'ms_watermarks_tesim', extract_xml('msPart/head/watermarks/p', nil) #	Filigrane	Watermarks
  to_field 'ms_motto_tesim', extract_xml('msPart/head/motto', nil) #	Motto	Motto
  to_field 'ms_locus_tesim', extract_xml('msPart/msContents/msItem/locus', nil) #	Locus	Locus
  to_field 'ms_author_tesim', (accumulate do |resource, *_| #	Autore	Author
    resource.xpath('msPart/msContents/msItem/author/alias/authorityAuthor[@rif="aut"]').map do |author|
      NameDisplay.new(
        author
      ).display
    end
  end)
  to_field 'ms_author_date_tesim', extract_xml('msPart/msContents/msItem/author/alias/authorityAuthor[@rif="aut"]/@date', nil)
  to_field 'ms_other_author_tesim', (accumulate do |resource, *_| #	Altro autore	Other author
    resource.xpath('msPart/msContents/msItem/name[@role="internal" or @role="external"]/alias/authorityAuthor[@rif="aut"]').map do |author|
      NameDisplay.new(
        author
      ).display
    end
  end)
  to_field 'ms_title_tesim', extract_xml('msPart/msContents/msItem/title[@type="title"]/@value', nil) #		Titolo	Title
  to_field 'ms_supplied_title_tesim', extract_xml('msPart/msContents/msItem/title[@type="supplied"]/@value', nil) #		Titolo supplito	Supplied title
  to_field 'ms_uniform_title_tesim', extract_xml('msPart/msContents/msItem/uniformTitle/alias/authorityTitleSeries[@rif="aut"]/@value', nil) #		Titolo uniforme	Uniform title
  to_field 'ms_rubric_tesim', extract_xml('msPart/msContents/msItem/rubric', nil) #	Rubrica	Rubric
  to_field 'ms_summary_tesim', extract_xml('msPart/msContents/msItem/summary', nil) #	Sommario	Summary
  to_field 'ms_incipit_text_tesim', extract_xml('msPart/msContents/msItem/incipit[@type="text"]/@value', nil) #		Incipit testo	Incipit text
  to_field 'ms_incipit_dedication_tesim', extract_xml('msPart/msContents/msItem/incipit[@type="dedication"]/@value', nil) #		Incipit dedica	Incipit dedication
  to_field 'ms_incipit_preface_tesim', extract_xml('msPart/msContents/msItem/incipit[@type="preface"]/@value', nil) #		Incipit prefazione	Incipit preface
  to_field 'ms_incipit_tesim', extract_xml('msPart/msContents/msItem/incipit[not(@type)]/@value', nil) #		Incipit	Incipit
  to_field 'ms_explicit_text_tesim', extract_xml('msPart/msContents/msItem/explicit[@type="text"]/@value', nil) #		Explicit testo	Explicit text
  to_field 'ms_explicit_dedication_tesim', extract_xml('msPart/msContents/msItem/explicit[@type="dedication"]/@value', nil) #		Explicit dedica	Explicit dedication
  to_field 'ms_explicit_preface_tesim', extract_xml('msPart/msContents/msItem/explicit[@type="preface"]/@value', nil) #		Explicit prefazione	Explicit preface
  to_field 'ms_explicit_tesim', extract_xml('msPart/msContents/msItem/explicit[not(@type)]/@value', nil) #		Explicit	Explicit
  to_field 'ms_type_of_document_tesim', extract_xml('msPart/msContents/msItem/note[@anchored and not(@anchored="yes")]', nil) #	Tipologia documento	Type of document
  to_field 'ms_general_note_tesim', extract_xml('msPart/msContents/msItem/note[@anchored="yes" or not(@anchored)]', nil) #	Nota	General note
  to_field 'ms_source_note_tesim', extract_xml('msPart/msContents/msItem/note[@anchored="sourceSYS"]', nil) #		Nota di fonte	Source note
  to_field 'ms_other_name_tesim', (accumulate do |resource, *_| #	Altro nome	Other name
    resource.xpath('msPart/msContents/msItem/name[@role!="internal" and @role!="external" or not(@role)]/alias/authorityAuthor[@rif="aut"]').map do |author|
      NameDisplay.new(
        author
      ).display
    end
  end)
  to_field 'ms_subject_tesim', extract_xml('msPart/msContents/msItem/keywords/term/alias/authoritySubject[@rif="aut"]', nil) #	Soggetto	Subject
  to_field 'ms_language_ssim', extract_xml('msPart/msContents/msItem/textLang', nil) #	Lingua	Language
  to_field 'ms_alphabet_ssim', extract_xml('msPart/msContents/msItem/textLang/@n', nil) #	Alfabeto	Alphabet
  to_field 'ms_colophon_tesim', extract_xml('msPart/msContents/msItem/colophon', nil) #	Colophon	Colophon
  to_field 'ms_secfol_tesim', extract_xml('msPart/msContents/msItem/writingSystem/secFol', nil) #	Secundum Folium	Secundum Folium
  to_field 'ms_bibl_tesim', extract_xml('msPart/msContents/msItem/bibl', nil) # Bibliography

  to_field 'ms_origin_tesim', extract_xml('msPart/history/origin/p', nil)
  to_field 'ms_provenance_tesim', extract_xml('msPart/history/provenance/p', nil)
  to_field 'ms_acquisition_tesim', extract_xml('msPart/history/acquisition/p', nil)
  to_field 'ms_history_tesim', extract_xml('msPart/history/p', nil)
  to_field 'ms_source_of_information_tesim', extract_xml('msPart/additional/adminInfo/recordHist/source/p', nil)
  to_field 'ms_availability_tesim', extract_xml('msPart/additional/adminInfo/availability/p', nil)
  to_field 'ms_custodial_history_tesim', extract_xml('msPart/additional/adminInfo/custodialHist/custEvent/p', nil)
  to_field 'ms_remarks_tesim', extract_xml('msPart/additional/adminInfo/remarks/p', nil)
end

# We're being too clever here; the composed fields below are getting indexed into the sections_ssm field as serialized JSON hashes
compose 'parts_ssm', ->(record, accumulator, _context) { accumulator.concat record.tei.xpath('//TEI.2/teiHeader/fileDesc/sourceDesc/msDescription[@n="n"]') } do
  extend TrajectPlus::Macros
  extend TrajectPlus::Macros::Xml
  to_field 'ms_date_ssim', extract_xml('msPart/msContents/msItem/origDate', nil) #	Datazione	Date
  to_field 'ms_date_mss_ssim', extract_xml('msPart/msContents/msItem/origDate/@n', nil) #		Datato	Dated Mss
  to_field 'ms_beginning_date_tesim', extract_xml('msPart/msContents/msItem/origDate/@notBefore', nil) #		Data inizio	Beginning date
  to_field 'ms_ending_date_tesim', extract_xml('msPart/msContents/msItem/origDate/@notAfter', nil) #		Data fine	Ending date
  to_field 'ms_date_of_text_tesim', extract_xml('msPart/msContents/msItem/origDate/@value', nil) #		Data testo	Date of text
  to_field 'ms_country_ssim', extract_xml('msPart/msContents/msItem/origPlace/country', nil) #	Paese	Country
  to_field 'ms_region_ssim', extract_xml('msPart/msContents/msItem/origPlace/region', nil) #	Regione	Region
  to_field 'ms_place_ssim', extract_xml('msPart/msContents/msItem/origPlace/settlement', nil) #	Localita	Place
  to_field 'ms_support_tesim', extract_xml('msPart/physDesc/support/p', nil) #	Materiale	Support
  to_field 'ms_overview_tesim', extract_xml('msPart/msContents/overview/p/@value', nil) #		Nota generale	Overview
  to_field 'ms_palimpsest_tesim', extract_xml('msPart/physDesc/palimpsest/p', nil) #	Palinsesto	Palimpsest

  to_field 'ms_locus_tesim', extract_xml('msPart/msContents/msItem/locus', nil) #	Locus	Locus
  to_field 'ms_author_tesim', extract_xml('msPart/msContents/msItem/author/alias/authorityAuthor[@rif="aut"]', nil) #	Autore	Author
  to_field 'ms_other_author_tesim', extract_xml('msPart/msContents/msItem/name[@role="internal" or @role="external"]/alias/authorityAuthor[@rif="aut"]', nil) #	Altro autore	Other author
  to_field 'ms_title_tesim', extract_xml('msPart/msContents/msItem/title[@type="title"]/@value', nil) #		Titolo	Title
  to_field 'ms_supplied_title_tesim', extract_xml('msPart/msContents/msItem/title[@type="supplied"]/@value', nil) #		Titolo supplito	Supplied title
  to_field 'ms_uniform_title_tesim', extract_xml('msPart/msContents/msItem/uniformTitle/alias/authorityTitleSeries[@rif="aut"]/@value', nil) #		Titolo uniforme	Uniform title
  to_field 'ms_rubric_tesim', extract_xml('msPart/msContents/msItem/rubric', nil) #	Rubrica	Rubric
  to_field 'ms_summary_tesim', extract_xml('msPart/msContents/msItem/summary', nil) #	Sommario	Summary
  to_field 'ms_incipit_text_tesim', extract_xml('msPart/msContents/msItem/incipit[@type="text"]/@value', nil) #		Incipit testo	Incipit text
  to_field 'ms_incipit_dedication_tesim', extract_xml('msPart/msContents/msItem/incipit[@type="dedication"]/@value', nil) #		Incipit dedica	Incipit dedication
  to_field 'ms_incipit_preface_tesim', extract_xml('msPart/msContents/msItem/incipit[@type="preface"]/@value', nil) #		Incipit prefazione	Incipit preface
  to_field 'ms_incipit_tesim', extract_xml('msPart/msContents/msItem/incipit[not(@type)]/@value', nil) #		Incipit	Incipit
  to_field 'ms_explicit_text_tesim', extract_xml('msPart/msContents/msItem/explicit[@type="text"]/@value', nil) #		Explicit testo	Explicit text
  to_field 'ms_explicit_dedication_tesim', extract_xml('msPart/msContents/msItem/explicit[@type="dedication"]/@value', nil) #		Explicit dedica	Explicit dedication
  to_field 'ms_explicit_preface_tesim', extract_xml('msPart/msContents/msItem/explicit[@type="preface"]/@value', nil) #		Explicit prefazione	Explicit preface
  to_field 'ms_explicit_tesim', extract_xml('msPart/msContents/msItem/explicit[not(@type)]/@value', nil) #		Explicit	Explicit
  to_field 'ms_type_of_document_tesim', extract_xml('msPart/msContents/msItem/note[@anchored and not(@anchored="yes")]', nil) #	Tipologia documento	Type of document
  to_field 'ms_general_note_tesim', extract_xml('msPart/msContents/msItem/note[@anchored="yes" or not(@anchored)]', nil) #	Nota	General note
  to_field 'ms_source_note_tesim', extract_xml('msPart/msContents/msItem/note[@anchored="sourceSYS"]', nil) #		Nota di fonte	Source note
  to_field 'ms_other_name_tesim', extract_xml('msPart/msContents/msItem/name[@role!="internal" and @role!="external" or not(@role)]/alias/authorityAuthor[@rif="aut"]', nil) #	Altro nome	Other name
  to_field 'ms_subject_tesim', extract_xml('msPart/msContents/msItem/keywords/term/alias/authoritySubject[@rif="aut"]', nil) #	Soggetto	Subject
  to_field 'ms_language_ssim', extract_xml('msPart/msContents/msItem/textLang', nil) #	Lingua	Language
  to_field 'ms_alphabet_ssim', extract_xml('msPart/msContents/msItem/textLang/@n', nil) #	Alfabeto	Alphabet
  to_field 'ms_colophon_tesim', extract_xml('msPart/msContents/msItem/colophon', nil) #	Colophon	Colophon
  to_field 'ms_secfol_tesim', extract_xml('msPart/msContents/msItem/writingSystem/secFol', nil) #	Secundum Folium	Secundum Folium
  to_field 'ms_bibl_tesim', extract_xml('msPart/msContents/msItem/bibl', nil) # Bibliography

  to_field 'ms_origin_tesim', extract_xml('msPart/history/origin/p', nil)
  to_field 'ms_provenance_tesim', extract_xml('msPart/history/provenance/p', nil)
  to_field 'ms_acquisition_tesim', extract_xml('msPart/history/acquisition/p', nil)
  to_field 'ms_history_tesim', extract_xml('msPart/history/p', nil)
  to_field 'ms_source_of_information_tesim', extract_xml('msPart/additional/adminInfo/recordHist/source/p', nil)
  to_field 'ms_availability_tesim', extract_xml('msPart/additional/adminInfo/availability/p', nil)
  to_field 'ms_custodial_history_tesim', extract_xml('msPart/additional/adminInfo/custodialHist/custEvent/p', nil)
  to_field 'ms_remarks_tesim', extract_xml('msPart/additional/adminInfo/remarks/p', nil)
end

each_record do |_record, context|
  context.output_hash['parts_ssm'] &&= context.output_hash['parts_ssm'].map(&:to_json)
end

# TODO: Should we add this here?
# to_field 'other_name_ssim', vatican_tei(
#   "TEI.2/teiHeader/fileDesc/titleStmt/respStmt/resp/name[@role!='internal' and @role!='external' or not(@role)]/alias/authorityAuthor[@rif='aut']"
# )
to_field 'name_ssim', copy('author_ssim')
to_field 'name_ssim', copy('other_author_ssim')
to_field 'name_ssim', copy('other_name_and_role_ssim')

to_field 'name_tesim', copy('author_ssim')
to_field 'name_tesim', copy('other_author_ssim')
to_field 'name_tesim', copy('other_name_ssim')

to_field 'collection_tesim', copy('collection_ssim')
to_field 'date_tesim', copy('date_ssim')
to_field 'language_tesim', copy('language_ssim')
to_field 'author_tesim', copy('author_ssim')
to_field 'author_tesim', copy('other_author_ssim')

to_field 'thumbnail_url_ssm', (accumulate { |resource, *_| resource.thumbnails })

to_field 'iiif_manifest_url_ssi', (accumulate { |resource, *_| resource.id })
