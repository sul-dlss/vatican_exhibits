# :nodoc:
module MiradorHelper
  # rubocop:disable MethodLength
  def mirador_options(manifest, canvas)
    {
      "language": I18n.default_locale,
      "mainMenuSettings": {
        "show": false
      },
      "buildPath": '/assets/',
      "saveSession": false,
      "data": [
        {
          "manifestUri": manifest,
          "location": 'Biblioteca Apostolica Vaticana'
        }
      ],
      "windowObjects": [{
        "loadedManifest": manifest,
        "canvasID": canvas,
        "bottomPanelVisible": false,
        "annotationCreation": false,
        "canvasControls": {
          "annotations": {
            "annotationLayer": true,
            "annotationState": canvas ? 'on' : 'off', # set the annotationState on whether or not a canvas is passed
            "annotationCreation": false
          }
        }
      }],
      "annotationEndpoint": {
        name: 'Annotot',
        module: 'AnnototEndpoint',
        options: {
          endpoint: annotot_path
        }
      },
      windowSettings: {
        canvasControls: {
          imageManipulation: {
            manipulationLayer: true,
            controls: {
              mirror: true
            }
          }
        }
      }
    }
  end
  # rubocop:enable MethodLength
end
