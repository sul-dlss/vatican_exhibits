(function (global) {
  var MetadataDetails;

  MetadataDetails = {
    init: function (el) {
      var _this = this;
      _this.addButton(el);
      _this.toggleButton(el);
    },

    addButton: function(el) {
      $(el).addClass('collapse');
      $(el).next().toggleClass('hidden');
    },

    toggleButton: function(el){
        $(el).next().on('click', function(){
          var button = $(this);
          var caret = $(button).find('.btn-caret');
          caret.toggleClass('caret-up caret-down');
          $(button).find('.btn-text-show, .btn-text-hide').toggleClass('hidden');
        });
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
