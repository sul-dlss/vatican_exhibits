SirTrevor.Locales.en.blocks = $.extend(SirTrevor.Locales.en.blocks, {
  mirador: {
    caption_label: 'Viewer caption',
    description: 'This widget displays items in a Mirador viewer, which enables exhibit visitors to view and compare images in a zoomable, interactive environment. Optionally, you can add a heading and/or text to be displayed above the Mirador viewer and a caption to be displayed below the viewer.',
    heading_label: 'Heading',
    mirador_modal: {
      header: '',
      instructions: '',
      options_label: '',
      options: {
        enable_public_annotations: '',
        display_by_default: '',
        change_page: '',
        adjust_zoom_level: '',
        change_view_type: '',
        show_hide_content_sidebar: '',
        show_hide_thumbnail_strip: ''
      }
    },
    source_location: {
      exhibit: {
        label: 'This exhibit',
        placeholder: 'Enter a title...'
      },
      exhibit_label: 'This exhibit',
      header: 'Source location of item',
      iiif: {
        button: 'Load IIIF item',
        label: 'IIIF manifest',
        placeholder: 'Enter a IIIF manifest URL...',
        errors: {
          invalidUrl: 'The manifest URL must include http or https.',
          unavailable: 'The manifest cannot be found. Verify that the manifest URL is publicly accessible.',
          malformed: 'The manifest does not comply with the IIIF spec.'
        }
      }
    },
    text_label: 'Text',
    title: 'Mirador Viewer'
  }
});
