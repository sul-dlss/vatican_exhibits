(function (global) {
  var MetadataDetails;

  MetadataDetails = {
    init: function (el) {
      var _this = this;
      _this.addButton(el);
      _this.toggleButton(el);
    },

    addButton: function(el) {
      var button = "<button type='button' class='btn btn-default btn-details' data-toggle='collapse' data-target='#metadataDetails' aria-expanded='false' aria-controls='metadataDetails'><span class='btn-text'>More details</span><span class='btn-caret caret-down'>&gt;&gt;</span></button>";
      $(el).after(button);
      $(el).addClass('collapse');
    },

    toggleButton: function(el){
        $(el).next().on('click', function(){
          var button = $(this);
          var linkText = $(button).find('.btn-text');
          var caret = $(button).find('.btn-caret');
          caret.toggleClass('caret-up caret-down');
          $(linkText).text(linkText.text() == 'More details' ? 'Fewer details' : 'More details' );
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
