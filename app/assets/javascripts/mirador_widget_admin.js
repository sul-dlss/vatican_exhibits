(function(global) {
  var Module = (function() {
    var MiradorSerializer = require('mirador_serializer');
    var sourceLocationSelector = 'input[type="radio"][data-behavior="source-location-select"]';
    var itemThreshold = 4;

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

    // Trigger the items-updated event when the block's nestable items
    // are changed so that the MiradorConfiguration is re-serialized
    function setupNestableChangeEvents(block) {
      block.find('[data-behavior="nestable"]').on('change', function() {
        block.trigger('items-updated', block);
      });
    }

    function setupMiradorModalEvents(block) {
      modalForBlock(block).find('[data-save-mirador-config]').on('click', function(context) {
        block.trigger('mirador-modal-closed', context);
      });
      modalForBlock(block).find('.annotations-checkbox').on('change', function(context) {
        block.trigger('annotations-available', context);
      });
      modalForBlock(block).find('.display-default-checkbox').on('change', function(context) {
        block.trigger('annotations-default-toggled', context);
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
        clearError(block);
        fetchSelectedItem(block, value);
      });
    }

    function modalMiradorSubmitListener(block) {
      block.on('mirador-modal-closed', function(e, value) {
        // Extract and merge config information
        var $modal = modalForBlock(block);
        var miradorInstance = $modal.find('iframe')[0].contentWindow.miradorInstance;
        var config = miradorInstance.saveController.currentConfig;
        var newConfig = {
          data: config.data,
          layout: config.layout,
          mainMenuSettings: config.mainMenuSettings,
          windowObjects: config.windowObjects.map(function(value) {
            return {
              slotAddress: value.slotAddress,
              viewType: value.viewType,
              canvasID: value.canvasID,
              loadedManifest: value.loadedManifest,
              sidePanelVisible: value.sidePanelVisible,
              windowOptions: value.windowOptions ? { osdBounds: value.windowOptions.osdBounds } : undefined
            };
          })
        };
        // Add config to hidden form.
        block.find('[name="mirador_config"]').replaceWith(
          createMiradorConfigInput(newConfig)
        );
        $modal.modal('hide')
      })
    }

    function setupAnnotationsListener(block) {
      // make checkboxes reflect accurate state.
      block.on('annotations-available', function(e, value) {
        var $modal = modalForBlock(block);
        var iframeContext = $modal.find('iframe')[0].contentWindow;
        var miradorInstance = iframeContext.miradorInstance;
        var available = value.currentTarget.checked;

        // reset the workspace settings if box is checked.
        if (available) {
          var config = miradorInstance.saveController.currentConfig;
          var windowConfigs = config.windowObjects.map(function(value) {
              return {
                slotAddress: value.slotAddress,
                viewType: value.viewType,
                canvasID: value.canvasID,
                loadedManifest: value.loadedManifest,
                sidePanelVisible: value.sidePanelVisible,
                windowOptions: value.windowOptions ? { osdBounds: value.windowOptions.osdBounds } : undefined
              };
          });
          // Disable the ability to view annotations for all new windows.
          miradorInstance.saveController.currentConfig
            .windowSettings.canvasControls.annotations
            .annotationsLayer = false;

          // clear existing windows
          miradorInstance.viewer.workspace.windows.forEach(function(window) {
            miradorInstance.eventEmitter.publish('REMOVE_WINDOW', window.id);
          });

          // reset original layout
          miradorInstance.eventEmitter.publish('RESET_WORKSPACE_LAYOUT', {layoutDescription: config.layout});

          // repopulate layout slots with new windows that take up
          // the new annotation setting on initialisation.
          // miradorInstance.viewer.workspace.slots.forEach(function(slot, index){
          //   console.log(windowConfigs);
          //   miradorInstance.eventEmitter.publish('ADD_WINDOW', windowConfigs[0]);
          // });

          modalForBlock(block).find('.display-default-checkbox').removeAttr('disabled');
          return;
        }

        modalForBlock(block).find('.display-default-checkbox').attr('disabled', true);
      });

      block.on('annotations-default-toggled', function(e, value) {

        var $modal = modalForBlock(block);
        var miradorInstance = $modal.find('iframe')[0].contentWindow.miradorInstance;
        var displayed = value.currentTarget.checked;

        // Enable the default toggle checkboxes.
        if (displayed) {

          miradorInstance.viewer.workspace.windows.forEach(function(window) {
            // necessary to initialise the menu state machine.
            // There is no mirador "action" for this setting.
            window.focusModules.ImageView.hud.annoState.displayOn();
          });

          console.log(miradorInstance.saveController.currentConfig);
          return;
        }

        miradorInstance.viewer.workspace.windows.forEach(function(window) {
          window.focusModules.ImageView.hud.annoState.displayOff();
        });

        console.log(miradorInstance.saveController.currentConfig);
      });
    }

    // Setup functions that need ot listen to when an item is successfully added to the items array
    function setupItemAddedListener(block) {
      block.on('item-added', function(e, eventObject) {
        addIiifItemToSection(eventObject.block, eventObject.manifest);
        sourceLocationInput(eventObject.block).val('');

        eventObject.block.trigger('items-updated', eventObject.block);
      });
    }

    // Setup functions that need ot listen to when an item is successfully removed to the items array
    function setupItemRemovedListener(block) {
      block.on('item-removed', function(e, eventObject) {
        eventObject.panel.remove();
        eventObject.block.trigger('items-updated', eventObject.block);
      });
    }

    function setupItemsUpdatedListener(block) {
      block.on('items-updated', function(e, eventBlock) {
        MiradorWidgetBlock.updateHiddenMiradorConfig($(eventBlock));
        toggleSourceLocationFieldset($(eventBlock));
        toggleConfigureMiradorButton($(eventBlock));
      });
    }

    // Setup function that listens to when an external IIIF manifest cannot be fetched
    function setupManifestErrorListener(block) {
      block.on('manifest-error', function(e, eventObject) {
        manifestError(eventObject.block, eventObject.error);
      })
    }

    function showSourceLocationInput(block, value) {
      block.find('[data-source-location]').hide();
      block.find('[data-source-location="' + value + '"]').show();
    }

    function sourceLocationFieldset(block) {
      return block.find('[data-behavior="mirador-source-location-fieldset"]');
    }

    function configureMiradorButton(block) {
      return block.find('.configure-mirador-button');
    }

    function modalForBlock(block) {
      return $('#' + block.data('mirador-block-id') + '-mirador-modal');
    }

    function toggleSourceLocationFieldset(block) {
      if (itemCount(block) < itemThreshold) {
        sourceLocationFieldset(block).show();
      } else {
        sourceLocationFieldset(block).hide();
      }
    }

    function toggleConfigureMiradorButton(block) {
      if (itemCount(block) > 0) {
        configureMiradorButton(block).show();
      } else {
        configureMiradorButton(block).hide();
      }
    }

    function createMiradorConfigInput(config) {
      var input = $('<input type="text" style="display:none;" name="mirador_config" />');
      input.val(JSON.stringify(config));
      return input;
    }

    // TODO: Add some sort of loading animation and clean it up after
    // complete to help reduce confusion with slow loading manifests
    function fetchSelectedItem(block, manifestUrl) {
      if (validUrl(block, manifestUrl) === false) {
        return false;
      }

      $.get(manifestUrl)
        .done(function(data) {
          if(typeof(data) == 'string') {
            data = JSON.parse(data);
          }
          if (validManifest(data)) {
            block.trigger('item-added', {
              block: block,
              manifest: data
            });
          } else {
            block.trigger('manifest-error', {
              block: block,
              error: 'malformed'
            });
          }
        }).fail(function(data) {
          block.trigger('manifest-error', {
            block: block,
            error: 'unavailable'
          });
        });
    }

    function addIiifItemToSection(block, manifest) {

      MiradorWidgetBlock.addItemToSection(block, {
        title: manifest.label,
        thumbnail: manifest.thumbnail ? manifest.thumbnail['@id'] : manifest.sequences[0].canvases[0].thumbnail['@id'],
        iiif_manifest_url: manifest['@id']
      }, false);
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

    function itemCount(block) {
      return block.find('[data-behavior="mirador-item"]').length;
    }

    function validManifest(manifest) {
      var hasContext = (manifest["@context"] || '').includes('iiif.io/api/presentation/2/context.json');
      var sequences = manifest["sequences"] || '';
      var hasCanvas = sequences.some(function(sequence) { return (sequence["canvases"] || '').length > 0 });
      return hasContext && hasCanvas;
    }

    function validUrl(block, manifestUrl) {
      if (manifestUrl.includes('http') || manifestUrl.includes('https')) {
        return true;
      } else {
        block.trigger('manifest-error', {
          block: block,
          error: 'invalidUrl'
        });
        return false;
      }
    }

    function manifestError(block, error) {
      if (error == 'invalidUrl') {
        var errorMsg = 'The manifest URL must include http or https.';
      } else if (error == 'unavailable') {
        var errorMsg = 'The manifest cannot be found. Verify that the manifest URL is publicly accessible.';
      } else if (error == 'malformed') {
        var errorMsg = 'The manifest does not comply with the IIIF spec.';
      }
      var input = sourceLocationInput(block).parent();
      var errorSpan = input.closest('[data-source-location]').find('.manifest-error');
      input.addClass('has-error');
      errorSpan.removeClass('hidden');
      errorSpan.text(errorMsg);
    }

    function clearError(block) {
      var input = sourceLocationInput(block).parent();
      var errorSpan = input.closest('[data-source-location]').find('.manifest-error');
      input.removeClass('has-error');
      errorSpan.addClass('hidden');
      errorSpan.text('');
    }

    return {
      init: function(block) {
        if (block.prop('data-mirador-block')) {
          return;
        }

        block.prop('data-mirador-block', true);

        this.setupEvents(block);
        this.setupListeners(block);

        showSourceLocationInput(block, sourceLocationValue(block));
        toggleSourceLocationFieldset(block);
        toggleConfigureMiradorButton(block);
      },

      updateHiddenMiradorConfig: function(block) {
        var manifestUrls = [];
        block.find('input[type="hidden"][data-behavior="mirador-item"]').each(function(i, val) {
          manifestUrls.push($(val).val());
        });
        var miradorSerializer = new MiradorSerializer(manifestUrls);

        block.find('[name="mirador_config"]').replaceWith(
          createMiradorConfigInput(miradorSerializer.miradorConfig())
        );
      },

      addItemToSection: function(block, itemObject, shouldTriggerEvent) {
        var miradorItemIndexes = [];
        block.find('input[type="hidden"][data-behavior="mirador-item"]').each(function() {
          miradorItemIndexes.push(parseInt($(this).prop('name').match(/(\d)/)[0]) + 1);
        });

        var index = (miradorItemIndexes.sort().pop() || 0);

        itemsSection(block).append(
          MiradorWidgetBlock.hiddenInput(index, itemObject)
        );

        // When the shouldTriggerEvent option is set to true (or not set, as it is the default behavior)
        // trigger the items-updated event.  Somebody calling MiradorWidgetBlock.addItemToSection should
        // only set shouldTriggerEvent to false if they do not want adding the item to trigger events
        // such as updating the mirador config based on the current items (e.g. Block initialization)
        if (shouldTriggerEvent || shouldTriggerEvent === undefined) {
          block.trigger('items-updated', block);
        }
      },

      setupEvents: function(block) {
        setupSourceLocationEvents(block);
        setupItemInputButtonEvents(block);
        setupNestableChangeEvents(block);
        setupMiradorModalEvents(block);
      },

      setupListeners: function(block) {
        setupSourceLocationInputListener(block);
        setupItemSubmittedListener(block);
        setupItemAddedListener(block);
        setupItemRemovedListener(block);
        setupItemsUpdatedListener(block);
        setupManifestErrorListener(block);
        modalMiradorSubmitListener(block);
        setupAnnotationsListener(block);
      },

      hiddenInput: function(index, object) {
        object.index = index;
        object.title = object.title || null;
        object.thumbnail = object.thumbnail || null;
        object.id = object.id || null;

        template = [
          '<li class="field form-inline dd-item dd3-item" data-resource-id="<%= id %>">',
            '<div>',
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
            '</div>',
          '</li>'
        ].join("\n");
        var $el = $(_.template(template, object)(object));
        $el.find('[data-item-grid-panel-remove]').on('click', function(e) {
          e.preventDefault();
          var block = $(this).closest('[data-behavior="mirador-widget"]');
          var panel = $(this).closest('.field');
          block.trigger('item-removed', {
            block: block,
            panel: panel
          });
        });

        return $el;
      }
    };
  })();

  global.MiradorWidgetBlock = Module;

  Module = (function() {
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
