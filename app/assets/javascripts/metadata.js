Blacklight.onLoad(function() {
  $('.btn-details').on('click', function(){
    var button = $(this);
    var linkText = $(button).find('.btn-text');
    var caret = $(button).find('.btn-caret')
    caret.toggleClass('caret-up');
    caret.toggleClass('caret-down');
    $(linkText).text(linkText.text() == 'More details' ? 'Fewer details' : 'More details' );
  });
})
