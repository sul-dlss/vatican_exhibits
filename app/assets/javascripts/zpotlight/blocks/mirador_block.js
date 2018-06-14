SirTrevor.Blocks.Mirador = (function() {

  return Spotlight.Block.Resources.extend({
    type: 'mirador',
    icon_name: 'item_features',

    /**
     * autocomplete_url, autocomplete_template, and transform_autocomplete_results
     * were copied from https://github.com/projectblacklight/spotlight/blob/master/app/assets/javascripts/spotlight/blocks/solr_documents_base_block.js
     */
    autocomplete_url: function() { return this.$instance().closest('form[data-autocomplete-exhibit-catalog-path]').data('autocomplete-exhibit-catalog-path').replace("%25QUERY", "%QUERY"); },
    autocomplete_template: function() { return '<div class="autocomplete-item{{#if private}} blacklight-private{{/if}}">{{#if thumbnail}}<div class="document-thumbnail thumbnail"><img src="{{thumbnail}}" /></div>{{/if}}<span class="autocomplete-title">{{title}}</span><br/><small>&nbsp;&nbsp;{{description}}</small></div>' },
    transform_autocomplete_results: function(response) {
      return $.map(response['docs'], function(doc) {
        return doc;
      })
    },

    title: function() {
      return i18n.t('blocks:mirador:title');
    },

    description: function() {
      return i18n.t('blocks:mirador:description');
    },

    editorHTML: function() {
      return _.template(this.template, this)(this);
    },

    blockGroup: function() { return i18n.t("blocks:group:items"); },

    onBlockRender: function() {
      MiradorWidgetAdmin.init();
    },

    /**
     * Overridden from https://github.com/projectblacklight/spotlight/blob/master/app/assets/javascripts/spotlight/blocks/resources_block.js
     * to add the updateHiddenMiradorConfig
     */
    createItemPanel: function(data) {
      var panel = MiradorWidgetBlock.hiddenInput(this.globalIndex++, {
        title: data.title,
        thumbnail: data.thumbnail,
        iiif_manifest_url: data.iiif_manifest,
        id: data.id
      });
      $(panel).appendTo($('.panels > ol', this.inner));
      MiradorWidgetBlock.updateHiddenMiradorConfig($(this.el));
      $('[data-behavior="nestable"]', this.inner).trigger('change');
    },

    afterLoadData: function(data) {
      var context = this;
      var itemsSection = $(this.$('[data-behavior="items-section"]'));
      var i = 0;
      $.each(data.items, function(key, item) {
        itemsSection.append(
          MiradorWidgetBlock.hiddenInput(i, item)
        );
        context.globalIndex++; // Make sure to update the globalIndex

        i++;
      });
    },

    template: [
      '<div class="clearfix" data-behavior="mirador-widget">',
        '<div class="widget-header">',
          '<%= description() %>',
        '</div>',
        '<div class="panels dd nestable-item-grid">',
          '<ol class="dd-list" data-behavior="items-section"></ol>',
        '</div>',
        '<fieldset class="mirador-source-location">',
          '<div class="clearfix">',
            '<legend><%= i18n.t("blocks:mirador:source_location:header") %>:</legend>',
            '<label for="<%= blockID + "_source_location_exhibit_label"  %>" class="radio-inline">',
              '<input type="radio" name="<%= blockID %>_source_location" id="<%= blockID + "_source_location_exhibit_label" %>" data-behavior="source-location-select" value="exhibit" checked> <%= i18n.t("blocks:mirador:source_location:exhibit:label") %>',
            '</label>',
            '<label for="<%= blockID + "_source_location_iiif_label"  %>" class="radio-inline">',
              '<input type="radio" name="<%= blockID %>_source_location" id="<%= blockID + "_source_location_iiif_label" %>" data-behavior="source-location-select" value="iiif"> <%= i18n.t("blocks:mirador:source_location:iiif:label") %>',
            '</label>',
          '</div>',
          '<div class="form-inline" data-source-location="exhibit">',
            '<div class="form-group">',
              '<input type="text" class="st-input-string form-control item-input-field" data-twitter-typeahead="true" placeholder="<%= i18n.t("blocks:mirador:source_location:exhibit:placeholder")%>"/>',
            '</div>',
          '</div>',
          '<div class="form-inline" data-source-location="iiif">',
            '<div class="form-group">',
              '<input type="text" placeholder="<%= i18n.t("blocks:mirador:source_location:iiif:placeholder") %>" data-behavior="source-location-input" />',
            '</div>',
            '<a class="btn btn-primary" href="javascript:;" data-behavior="source-location-submit"><%= i18n.t("blocks:mirador:source_location:iiif:button") %></a>',
          '</div>',
        '</fieldset>',
        '<div>',
          '<label for="<%= blockID + "_heading"  %>" class="control-label"><%= i18n.t("blocks:mirador:heading_label") %></label>',
          '<input id="<%= blockID + "_heading" %>" type="text" name="heading" />',
        '</div>',
        '<div>',
          '<label for="<%= blockID + "_text"  %>" class="control-label"><%= i18n.t("blocks:mirador:text_label") %></label>',
          '<textarea name="text" class="form-control"></textarea>',
        '</div>',
        '<div>',
          '<label for="<%= blockID + "_caption"  %>" class="control-label"><%= i18n.t("blocks:mirador:caption_label") %></label>',
          '<input type="text" name="caption" />',
        '</div>',
        '<div>',
          '<input type="text" style="display:none;" name="mirador_config" />',
        '</div>',
      '</div>'
    ].join("\n")
  });
})();
