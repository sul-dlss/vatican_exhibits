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
        fetchSelectedItem(block, value);
      });
    }

    // Setup functions that need ot listen to when an item is successfully added to the items array
    function setupItemAddedListener(block) {
      block.on('item-added', function(e, eventObject) {
        appendItemToSection(eventObject.block, eventObject.manifest);
        MiradorWidgetBlock.updateHiddenMiradorConfig(eventObject.block);
        sourceLocationInput(block).val('');
      });
    }

    // Setup functions that need ot listen to when an item is successfully removed to the items array
    function setupItemRemovedListener(block) {
      block.on('item-removed', function(e, eventObject) {
        eventObject.panel.remove();
        MiradorWidgetBlock.updateHiddenMiradorConfig(eventObject.block);
      });
    }

    function showSourceLocationInput(block, value) {
      block.find('[data-source-location]').hide();
      block.find('[data-source-location="' + value + '"]').show();
    }

    // TODO: Add some sort of loading animation and clean it up after
    // complete to help reduce confusion with slow loading manifests
    function fetchSelectedItem(block, manifestUrl) {
      $.get(manifestUrl)
       .done(function(data) {
         block.trigger('item-added', { block: block, manifest: data });
       });
    }

    function appendItemToSection(block, manifest) {
      var index = block.find('input[type="hidden"][data-behavior="mirador-item"]').length;

      if(typeof(manifest) == 'string') {
        manifest = JSON.parse(manifest);
      }

      itemsSection(block).append(
        MiradorWidgetBlock.hiddenInput(index, {
          title: manifest.label,
          thumbnail: manifest.thumbnail ? manifest.thumbnail['@id'] : manifest.sequences[0].canvases[0].thumbnail['@id'],
          iiif_manifest_url: manifest['@id']
        })
      );
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

      updateHiddenMiradorConfig(block) {
        var manifestUrls = [];
        block.find('input[type="hidden"][data-behavior="mirador-item"]').each(function(i, val) {
          manifestUrls.push($(val).val());
        });
        var miradorSerializer = new MiradorSerializer(manifestUrls);
        var template = [
          '<input type="text" style="display:none;" name="mirador_config" value=\'' +
            JSON.stringify(miradorSerializer.miradorConfig()) +
          '\'/>',
        ].join("\n");

        block.find('[name="mirador_config"]').replaceWith(_.template(template));
      },

      setupEvents: function(block) {
        setupSourceLocationEvents(block);
        setupItemInputButtonEvents(block);
      },

      setupListeners: function(block) {
        setupSourceLocationInputListener(block);
        setupItemSubmittedListener(block);
        setupItemAddedListener(block);
        setupItemRemovedListener(block);
      },

      hiddenInput: function(index, object) {
        object.index = index;
        object.title = object.title || null;
        object.thumbnail = object.thumbnail || null;
        object.id = object.id || null;

        template = [
          '<li class="field form-inline dd-item dd3-item" data-resource-id="<%= id %>">',
            '<div class="dd-handle dd3-handle">Drag</div>',
            '<div class="dd3-content panel panel-default">',
              '<div class="panel-heading item-grid">',
                '<div class="pic thumbnail"><img src="<%= thumbnail %>" /></div>',
                '<div class="main">',
                  '<div class="title panel-title"><%= title %></div>',
                  '<div><%= iiif_manifest_url %></div>',
                '</div>',
                '<input type="hidden" name="items[item_<%= index %>][id]" value="<%= id %>" />',
                '<input type="hidden" name="items[item_<%= index %>][title]" value="<%= title %>" />',
                '<input type="hidden" name="items[item_<%= index %>][thumbnail]" value="<%= thumbnail %>" />',
                '<input type="hidden" name="items[item_<%= index %>][iiif_manifest_url]" value="<%= iiif_manifest_url %>" data-behavior="mirador-item" />',
                '<div class="remove pull-right">',
                  '<a data-item-grid-panel-remove="true" href="#">Remove</a>',
                '</div>',
              '</div>',
            '</div>',
          '</li>'
        ].join("\n");
        var $el = $(_.template(template, object)(object));
        $el.find('[data-item-grid-panel-remove]').on('click', function(e) {
          e.preventDefault();
          var block = $(this).closest('[data-behavior="mirador-widget"]');
          var panel = $(this).closest('.field');
          block.trigger('item-removed', { block: block, panel: panel });
        });

        return $el;
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
