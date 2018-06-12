SirTrevor.Blocks.Mirador = (function() {

  return Spotlight.Block.extend({
    type: 'mirador',
    icon_name: 'item_features',

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

    afterLoadData: function(data) {
      var itemsSection = $(this.$('[data-behavior="items-section"]'));
      var i = 0;
      $.each(data.items, function(key, item) {
        itemsSection.append(
          MiradorWidgetBlock.hiddenInput(i, item.iiif_manifest_url)
        );

        i++;
      });
    },

    template: [
      '<div class="clearfix" data-behavior="mirador-widget">',
        '<div class="widget-header">',
          '<%= description() %>',
        '</div>',
        '<div data-behavior="items-section"></div>',
        '<fieldset class="mirador-source-location">',
          '<div class="clearfix">',
            '<legend><%= i18n.t("blocks:mirador:source_location:header") %>:</legend>',
            '<label for="<%= blockID + "_source_location_exhibit_label"  %>" class="radio-inline">',
              '<input type="radio" name="<%= blockID %>_source_location" id="<%= blockID + "_source_location_exhibit_label" %>" data-behavior="source-location-select" value="exhibit"> <%= i18n.t("blocks:mirador:source_location:exhibit:label") %>',
            '</label>',
            '<label for="<%= blockID + "_source_location_iiif_label"  %>" class="radio-inline">',
              '<input type="radio" name="<%= blockID %>_source_location" id="<%= blockID + "_source_location_iiif_label" %>" data-behavior="source-location-select" value="iiif"> <%= i18n.t("blocks:mirador:source_location:iiif:label") %>',
            '</label>',
          '</div>',
          '<div class="form-inline" data-source-location="exhibit">',
            '<div class="form-group">',
              '<input type="text" placeholder="<%= i18n.t("blocks:mirador:source_location:exhibit:placeholder") %>" data-behavior="source-location-input" />',
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
          '<input type="hidden" name="mirador_config"/>',
        '</div>',
      '</div>'
    ].join("\n")
  });
})();
