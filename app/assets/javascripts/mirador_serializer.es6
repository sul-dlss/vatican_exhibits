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
      mainMenuSettings: {
        show: false,
      },
      windowObjects: this.manifestUrls.map((url, index) => ({
        loadedManifest: url,
        viewType: 'ImageView',
        slotAddress: this.constructor.slotAddress(index, this.manifestUrls.length),
      })),
      windowSettings: {
        displayLayout: false,
        layoutOptions: {
          close: false,
        },
      },
    };
  }

  /**
   * A Mirador slot address based on image position
   * @returns {(string|null)}
   */
  static slotAddress(index, total) {
    if (total < 2) {
      return null;
    }

    switch (index) {
      case 0:
        return 'column1.row1.column1';
      case 1:
        return 'column1.row1.column2';
      case 2:
        return 'column1.row2.column1';
      case 3:
        return 'column1.row2.column2';
      default:
        return null;
    }
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
        return this.constructor.twoUpLayout();
      case 3:
        return this.twoUpOneAcrossLayout();
      case 4:
        return this.twoByTwoLayout();
      default:
        return null;
    }
  }

  /**
   * Creates a mirador layout object for a simple two up/side-by-side display
   * @returns {object}
   */
  static twoUpLayout() {
    return {
      type: 'column',
      address: 'column1',
      children: [
        {
          type: 'row',
          address: 'column1.row1',
          children: [
            {
              type: 'column',
              depth: 2,
              address: 'column1.row1.column1',
            },
            {
              type: 'column',
              depth: 2,
              address: 'column1.row1.column2',
            },
          ],
        },
      ],
    };
  }

  /**
   * Creates a mirador layout object that has two rows,
   * This builds off of the twoUpLayout() by adding a new row with a single column.
   * @returns {object}
   */
  twoUpOneAcrossLayout() {
    const layout = this.constructor.twoUpLayout();
    layout.children.push({
      type: 'row',
      address: 'column1.row2',
      children: [
        {
          type: 'column',
          depth: 2,
          address: 'column1.row2.column1',
        },
      ],
    });

    return layout;
  }

  /**
   * Creates a mirador layout object that has two rows,
   * This builds off of the twoUpOneAcrossLayout() by adding a new column to the second row.
   * @returns {object}
   */
  twoByTwoLayout() {
    const layout = this.twoUpOneAcrossLayout();
    layout.children[1].children.push({
      type: 'column',
      depth: 2,
      address: 'column1.row2.column2',
    });

    return layout;
  }
}
