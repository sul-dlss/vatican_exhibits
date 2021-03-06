var miradorInstance;
$(document).on('ready turbolinks:load', function() {
  $('[data-miradorfromscratch]').each(function(i, value) {

    // Setup Mirador to use config already existing in parent form
    parent.$('[data-behavior="mirador-modal"]').on('shown.bs.modal', function (e) {
      var block = $(e.relatedTarget).data('block');
      var miradorConfig = JSON.parse(parent.$('#' + block).find('[name="mirador_config"]').val());
      var neededConfig = $.extend({
        id: block + 'mirador_id',
        buildPath: '/assets/',
        i18nPath: '',
        imagesPath: ''
      }, miradorConfig);
      miradorInstance = Mirador(neededConfig);
    });
  });
});
