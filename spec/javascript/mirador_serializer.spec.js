import MiradorSerializer from '../../app/assets/javascripts/mirador_serializer.es6';

describe('MiradorSerializer', () => {
  describe('constructor', () => {
    it('sets instance variables', () => {
      const miradorSerializer = new MiradorSerializer(['a', 'b']);
      expect(miradorSerializer.manifestUrls).toEqual(['a', 'b']);
    });
  });
  describe('layout', () => {
    it('returns a different layout based on number of urls', () => {
      const miradorSerializer = new MiradorSerializer(['a']);
      expect(miradorSerializer.layout()).toBe('1x1');
      miradorSerializer.manifestUrls.push('b');
      expect(miradorSerializer.layout()).toBe('1x2');
      miradorSerializer.manifestUrls.push('c');
      expect(miradorSerializer.layout()).toBe('2x2');
      miradorSerializer.manifestUrls.push('d');
      expect(miradorSerializer.layout()).toBe('2x2');
      miradorSerializer.manifestUrls.push('e');
      expect(miradorSerializer.layout()).toBe(null);
    });
  });
  describe('miradorConfig', () => {
    it('sets up a mirador config object', () => {
      const miradorSerializer = new MiradorSerializer(['a']);
      expect(miradorSerializer.miradorConfig()).toEqual({
        data: [
          {
            manifestUri: 'a',
          },
        ],
        language: 'en',
        layout: '1x1',
        windowObjects: [
          {
            loadedManifest: 'a',
            viewType: 'ImageView',
          },
        ],
      });
    });
  });
});
