##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog

  before_action do
    blacklight_config.show.partials -= [:viewer] unless action_name == 'show'
  end

  configure_blacklight do |config|
    config.index.display_type_field = :resource_type_ssim
    config.show.oembed_field = :oembed_url_ssm
    config.show.partials.insert(1, :oembed)
    config.show.partials.insert(1, :viewer)
    config.show.partials.insert(4, :curatorial_narrative)
    config.show.partials << :parts
    config.show.partials << :annotations
    config.view.parts.partials = [:part_header, :part_show]
    config.view.parts.if = false

    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]

    config.view.embed.partials = [:viewer]

    config.index.document_actions.clear
    config.show.document_actions.clear
    config.index.document_actions[:bookmark].if = false
    config.show.document_actions[:bookmark].if = false
    config.navbar.partials.clear

    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    config.break_seperator = {
      last_word_connector: '<br/>',
      two_words_connector: '<br/>',
      words_connector: '<br/>'
    }

    config.comma_seperator = {
      last_word_connector: ', ',
      two_words_connector: ', ',
      words_connector: ', '
    }

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tesim'

    config.add_index_field 'resource_type_ssim', section: :general
    config.add_index_field 'collection_ssim', section: :general
    config.add_index_field 'date_ssim', separator_options: config.comma_seperator
    config.add_index_field 'beginning_date_ssim', separator_options: config.comma_seperator
    config.add_index_field 'ending_date_ssim', separator_options: config.comma_seperator
    config.add_index_field 'dated_mss_ssim', separator_options: config.comma_seperator
    config.add_index_field 'manuscript_shelfmark_ssim', helper_method: :link_to_manuscript
    config.add_index_field 'annotation_text_tesim', helper_method: :render_minimally_styled_narrative_field
    config.add_index_field 'annotation_tags_en_ssim', link_to_search: true, if: ->(*_) { I18n.locale =~ /en/ }
    config.add_index_field 'annotation_tags_it_ssim', link_to_search: true, if: ->(*_) { I18n.locale =~ /it/ }
    config.add_index_field 'curatorial_narrative_tesim',
                           helper_method: :render_minimally_styled_narrative_field,
                           immutable: { show: false }.merge(config.view.keys.map { |k| [k, false] }.to_h)

    config.add_show_field 'iiif_structure_label_ssim'
    config.add_show_field 'ms_collection_ssim', section: :general, link_to_search: true
    config.add_show_field 'ms_shelfmark_tesim', section: :general
    config.add_show_field 'ms_library_tesim', section: :general
    config.add_show_field 'ms_ocelli_nominum_tesim', section: :general
    config.add_show_field 'ms_date_ssim', section: :general, link_to_search: true, separator_options: config.comma_seperator
    config.add_show_field 'ms_date_mss_ssim', section: :general, link_to_search: true, separator_options: config.comma_seperator
    config.add_show_field 'ms_beginning_date_tesim', section: :general, separator_options: config.comma_seperator
    config.add_show_field 'ms_ending_date_tesim', section: :general, separator_options: config.comma_seperator
    config.add_show_field 'ms_date_of_text_tesim', section: :general, separator_options: config.comma_seperator
    config.add_show_field 'ms_country_ssim', section: :general, link_to_search: true
    config.add_show_field 'ms_region_ssim', section: :general, link_to_search: true
    config.add_show_field 'ms_place_ssim', section: :general, link_to_search: true
    config.add_show_field 'ms_support_tesim', section: :general
    config.add_show_field 'ms_physical_shapes_tesim', section: :general
    config.add_show_field 'ms_height_tesim', section: :general
    config.add_show_field 'ms_width_tesim', section: :general
    config.add_show_field 'ms_depth_tesim', section: :general
    config.add_show_field 'ms_extent_tesim', section: :general
    config.add_show_field 'ms_content_tesim', section: :general
    config.add_show_field 'ms_overview_tesim', section: :general
    config.add_show_field 'ms_bibl_tesim'
    config.add_show_field 'ms_collation_tesim'
    config.add_show_field 'ms_layout_tesim'
    config.add_show_field 'ms_foliation_tesim'
    config.add_show_field 'ms_writing_tesim'
    config.add_show_field 'ms_writing_note_tesim'
    config.add_show_field 'ms_music_notation_tesim'
    config.add_show_field 'ms_punctuation_tesim'
    config.add_show_field 'ms_decoration_tesim'
    config.add_show_field 'ms_decoration_note_tesim'
    config.add_show_field 'ms_binding_tesim'
    config.add_show_field 'ms_binding_note_tesim'
    config.add_show_field 'ms_additions_tesim'
    config.add_show_field 'ms_condition_tesim'
    config.add_show_field 'ms_signatures_tesim'
    config.add_show_field 'ms_catchwords_tesim'
    config.add_show_field 'ms_palimpsest_tesim'
    config.add_show_field 'ms_physical_description_tesim'
    config.add_show_field 'ms_heraldry_tesim'
    config.add_show_field 'ms_seal_tesim'
    config.add_show_field 'ms_format_tesim'
    config.add_show_field 'ms_watermarks_tesim'
    config.add_show_field 'ms_motto_tesim'
    config.add_show_field 'ms_locus_tesim'
    config.add_show_field 'ms_author_tesim', separator_options: config.break_seperator
    config.add_show_field 'ms_other_author_tesim', separator_options: config.break_seperator
    config.add_show_field 'ms_title_tesim'
    config.add_show_field 'ms_supplied_title_tesim'
    config.add_show_field 'ms_uniform_title_tesim'
    config.add_show_field 'ms_rubric_tesim'
    config.add_show_field 'ms_summary_tesim'
    config.add_show_field 'ms_incipit_text_tesim'
    config.add_show_field 'ms_incipit_dedication_tesim'
    config.add_show_field 'ms_incipit_preface_tesim'
    config.add_show_field 'ms_incipit_tesim'
    config.add_show_field 'ms_explicit_text_tesim'
    config.add_show_field 'ms_explicit_dedication_tesim'
    config.add_show_field 'ms_explicit_preface_tesim'
    config.add_show_field 'ms_explicit_tesim'
    config.add_show_field 'ms_type_of_document_tesim'
    config.add_show_field 'ms_general_note_tesim'
    config.add_show_field 'ms_source_note_tesim'
    config.add_show_field 'ms_other_name_tesim', separator_options: config.break_seperator
    config.add_show_field 'ms_subject_tesim'
    config.add_show_field 'ms_language_ssim', link_to_search: true
    config.add_show_field 'ms_alphabet_ssim', link_to_search: true
    config.add_show_field 'ms_colophon_tesim'
    config.add_show_field 'ms_secfol_tesim'
    config.add_show_field 'ms_origin_tesim'
    config.add_show_field 'ms_provenance_tesim'
    config.add_show_field 'ms_acquisition_tesim'
    config.add_show_field 'ms_history_tesim'
    config.add_show_field 'ms_source_of_information_tesim', section: :administrative
    config.add_show_field 'ms_availability_tesim', section: :administrative
    config.add_show_field 'ms_custodial_history_tesim', section: :administrative
    config.add_show_field 'ms_remarks_tesim', section: :administrative

    config.add_facet_field 'resource_type_ssim', limit: true
    config.add_facet_field 'collection_ssim', limit: true
    config.add_facet_field 'date_ssim', limit: true
    config.add_facet_field 'name_ssim', limit: true
    config.add_facet_field 'place_ssim', limit: true
    config.add_facet_field 'annotation_tags_facet_en_ssim', sort: 'index',
                                                            limit: 9999,
                                                            partial: 'blacklight/hierarchy/facet_hierarchy',
                                                            if: ->(*_) { I18n.locale =~ /en/ }
    config.add_facet_field 'annotation_tags_facet_it_ssim', sort: 'index',
                                                            limit: 9999,
                                                            partial: 'blacklight/hierarchy/facet_hierarchy',
                                                            if: ->(*_) { I18n.locale =~ /it/ }
    config.add_facet_field 'language_ssim', limit: true
    config.facet_display = {
      hierarchy: {
        'annotation_tags_facet_en' => [['ssim'], ':'],
        'annotation_tags_facet_it' => [['ssim'], ':']
      }
    }
    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')
    config.add_search_field 'shelfmark_tsim'
    config.add_search_field 'title_tesim'
    config.add_search_field 'author_tesim'
    config.add_search_field 'name_tesim'
    config.add_search_field 'incipit_tesim'
    config.add_search_field 'explicit_tesim'
    config.add_search_field 'overview_tesim'
    config.add_search_field 'summary_tesim'

    config.add_sort_field 'relevance', sort: 'score desc, shelfmark_ssi asc',
                                       label: I18n.t('spotlight.search.fields.sort.relevance')

    config.add_facet_fields_to_solr_request!
    config.add_field_configuration_to_solr_request!

    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true
  end
end
