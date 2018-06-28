var miradorInstance;
$(document).on('ready turbolinks:load', () => {
  $('[data-miradorfromscratch]').each(function(i, value) {
    
    // Setup Mirador to use config already existing in parent form
    parent.$('#mirador-modal').on('shown.bs.modal', function () {
      var miradorConfig = JSON.parse(parent.$('[name="mirador_config"]').val());
      var neededConfig = $.extend({
        id: 'miradorId',
        buildPath: '/assets/',
        i18nPath: '',
        imagesPath: ''
      }, miradorConfig);
      miradorInstance = Mirador(neededConfig);
    });
  });
});
