export default class MiradorSerializer {
  /**
   * @param {array} manifestUrls - an array of manifest Urls
   */
  constructor(manifestUrls) {
    this.manifestUrls = manifestUrls;
  }

  /**
   * Creates a mirador config object
   * @returns {object}
   */
  miradorConfig() {
    return {
      language: 'en', // TODO: Figure out a better way to do this (configured from Rails app)
      data: this.manifestUrls.map(url => ({
        manifestUri: url,
      })),
      layout: this.layout(),
      windowObjects: this.manifestUrls.map(url => ({
        loadedManifest: url,
        viewType: 'ImageView',
      })),
    };
  }

  /**
   * A Mirador layout to use
   * @returns {(string|null)}
   */
  layout() {
    switch (this.manifestUrls.length) {
      case 1:
        return '1x1';
      case 2:
        return '1x2';
      case 3:
        return '2x2'; // TODO: Fix this if there is a better layout
      case 4:
        return '2x2';
      default:
        return null;
    }
  }
}
