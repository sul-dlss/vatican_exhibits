(function (global) {
  var MetadataDetails;

  MetadataDetails = {
    init: function (el) {
      var _this = this;
      _this.addButton(el);
    },

    addButton: function(el) {
      $(el).addClass('collapse');
      $(el).next().toggleClass('collapsed');
      $(el).next().removeClass('hidden');
    }
  };

  global.MetadataDetails = MetadataDetails;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('[data-behavior="metadata-details"]').each(function (i, element) {
    MetadataDetails.init(element);
  });
});
