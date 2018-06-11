# :nodoc:
module MiradorHelper
  # rubocop:disable MethodLength
  def mirador_options(manifest, canvas)
    {
      "language": I18n.default_locale,
      "mainMenuSettings": {
        "show":  false
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
            "annotationState": 'on'
          }
        }
      }]
    }
  end
  # rubocop:enable MethodLength
end
