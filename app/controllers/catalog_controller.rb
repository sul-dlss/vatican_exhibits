##
# Simplified catalog controller
class CatalogController < ApplicationController
  include Blacklight::Catalog

  configure_blacklight do |config|
          config.show.oembed_field = :oembed_url_ssm
          config.show.partials.insert(1, :oembed)

    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]


    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      fl: '*'
    }

    config.document_solr_path = 'get'
    config.document_unique_id_param = 'ids'

    config.show.partials.insert(1, :viewer)

    # solr field configuration for search results/index views
    config.index.title_field = 'full_title_tesim'

    config.add_index_field 'resource_type_ssim', label: 'Resource type'
    config.add_index_field 'collection_ssim', label: 'Collection'
    config.add_index_field 'date_ssim', label: 'Date'
    config.add_index_field 'beginning_date_ssim', label: 'Beginning date'
    config.add_index_field 'ending_date_ssim', label: 'Ending date'
    config.add_index_field 'dated_mss_ssim', label: 'Dated Mss'

    config.add_facet_field 'resource_type_ssim', label: 'Resource type'
    config.add_facet_field 'collection_ssim', label: 'Collection'
    config.add_facet_field 'date_ssim', label: 'Date'
    config.add_facet_field 'name_ssim', label: 'Name'
    config.add_facet_field 'place_ssim', label: 'Place'
    config.add_facet_field 'annotation_tags_ssim', label: 'Tags', sort: 'index', partial: 'blacklight/hierarchy/facet_hierarchy'
    config.add_facet_field 'language_ssim', label: 'Language'
    config.facet_display = {
      hierarchy: {
        'annotation_tags' => [['ssim'], '|']
      }
    }
    config.add_search_field 'all_fields', label: I18n.t('spotlight.search.fields.search.all_fields')
    config.add_search_field 'shelfmark_tsim', label: 'Shelfmark'
    config.add_search_field 'title_tesim', label: 'Title'
    config.add_search_field 'author_tesim', label: 'Author'
    config.add_search_field 'name_tesim', label: 'Name'
    config.add_search_field 'incipit_tesim', label: 'Incipit'
    config.add_search_field 'explicit_tesim', label: 'Explicit'
    config.add_search_field 'overview_tesim', label: 'Overview'
    config.add_search_field 'summary_tesim', label: 'Summary'

    config.add_sort_field 'relevance', sort: 'score desc', label: I18n.t('spotlight.search.fields.sort.relevance')

    config.add_facet_fields_to_solr_request!
    config.add_field_configuration_to_solr_request!

    # Set which views by default only have the title displayed, e.g.,
    # config.view.gallery.title_only_by_default = true
  end
end
