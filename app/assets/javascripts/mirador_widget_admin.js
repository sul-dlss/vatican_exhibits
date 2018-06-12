(function(global) {
  var Module = (function() {
    var MiradorSerializer = require('mirador_serializer');
    var sourceLocationSelector = 'input[type="radio"][data-behavior="source-location-select"]';

    // Trigger an event when the exhibits/iiif radio button is changed
    // that contains the value of the radio button that was selected
    function setupSourceLocationEvents(block) {
      sourceLocation(block).on('change', function() {
        block.trigger('source-selected', this.value);
      });
    }

    // Trigger an event when the add item form is submitted
    // that contains the value of the current text input
    function setupItemInputButtonEvents(block) {
      sourceLocationSubmit(block).on('click', function() {
        block.trigger('item-submitted', sourceLocationInput(block).val());
      });
    }

    // Setup functions that need to listen to the source selected event
    function setupSourceLocationInputListener(block) {
      block.on('source-selected', function(e, value) {
        showSourceLocationInput(block, value);
      });
    }

    // Setup functions that need to listen to when the add item form is submitted
    function setupItemSubmittedListener(block) {
      block.on('item-submitted', function(e, value) {
        addSelectedItem(block, value);
        block.find('[name="mirador_config"]').replaceWith(updateHiddenMiradorConfig(block));
      });
    }

    function showSourceLocationInput(block, value) {
      block.find('[data-source-location]').hide();
      block.find('[data-source-location="' + value + '"]').show();
    }

    function addSelectedItem(block, value) {
      itemsSection(block).append(itemTemplate(block, value));
    }

    function itemTemplate(block, value) {
      var index = block.find('input[type="hidden"][data-behavior="mirador-item"]').length;
      return MiradorWidgetBlock.hiddenInput(index, value);
    }

    function sourceLocationSubmit(block) {
      return block.find('[data-behavior="source-location-submit"]');
    }

    function sourceLocationValue(block) {
      return block.find(sourceLocationSelector + ':checked').val() || sourceLocation(block).val();
    }

    function sourceLocation(block) {
      return block.find(sourceLocationSelector);
    }

    function sourceLocationInput(block) {
      return block.find('[data-behavior="source-location-input"]:visible');
    }

    function itemsSection(block) {
      return block.find('[data-behavior="items-section"]');
    }

    function updateHiddenMiradorConfig(block) {
      var manifestUrls = [];
      block.find('input[type="hidden"][data-behavior="mirador-item"]').each(function(i, val) {
        manifestUrls.push($(val).val());
      });
      var miradorSerializer = new MiradorSerializer(manifestUrls);
      var template = [
        '<input type="hidden" name="mirador_config" value=\'' + 
          JSON.stringify(miradorSerializer.miradorConfig()) + 
        '\'/>',
      ].join("\n");

      return _.template(template);        
    }

    return {
      init: function(block) {
        if(block.prop('data-mirador-block')) {
          return;
        }

        block.prop('data-mirador-block', true);

        this.setupEvents(block);
        this.setupListeners(block);
        showSourceLocationInput(block, sourceLocationValue(block));
      },

      setupEvents: function(block) {
        setupSourceLocationEvents(block);
        setupItemInputButtonEvents(block);
      },

      setupListeners: function(block) {
        setupSourceLocationInputListener(block);
        setupItemSubmittedListener(block);
      },

      hiddenInput: function(index, value) {
        var obj = { index: index, manifest: value };

        template = [
          '<div>',
            value,
            '<input type="hidden" name="items[item_<%= index %>][iiif_manifest_url]" value="<%= manifest %>" data-behavior="mirador-item" />',
          '</div>'
        ].join("\n");

        return _.template(template, obj)(obj);
      }
    };
  })();

  global.MiradorWidgetBlock = Module;

  Module = (function(){
    function blocks() {
      return $('[data-behavior="mirador-widget"]');
    }

    return {
      init: function() {
        blocks().each(function() {
          MiradorWidgetBlock.init($(this));
        });
      }
    };
  })();

  global.MiradorWidgetAdmin = Module;

})(this);
