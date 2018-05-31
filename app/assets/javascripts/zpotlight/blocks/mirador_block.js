SirTrevor.Blocks.Mirador = (function() {

  return SirTrevor.Block.extend({
    formable: true,
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

    template: [
      '<div class="clearfix">',
        '<div class="widget-header">',
          '<%= description() %>',
        '</div>',
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
      '</div>'
    ].join("\n")
  });
})();
