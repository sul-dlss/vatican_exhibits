require 'rails_helper'

RSpec.describe 'Bibliography resource integration test', type: :feature do
  subject(:bibliograpy_resource) do
    VaticanIiifResource.new(
      iiif_url_list: "https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json\
         \n https://digi.vatlib.it/iiif/MSS_Chig.R.V.29/manifest.json",
      exhibit: exhibit
    )
  end

  let(:exhibit) { FactoryBot.create(:exhibit) }

  before do
    ['MSS_Barb.gr.252', 'MSS_Chig.R.V.29'].each do |v|
      stub_request(:get, "https://digi.vatlib.it/iiif/#{v}/manifest.json")
        .to_return(body: stubbed_manifest("#{v}.json"))
    end
    stub_request(:get, 'https://digi.vatlib.it/tei/Barb.gr.252.xml')
      .to_return(body: stubbed_tei('Barb.gr.252.xml'))
    stub_request(:get, 'https://digi.vatlib.it/tei/Chig.R.V.29.xml')
      .to_return(status: 404)
  end

  it 'can write the document to solr' do
    expect { bibliograpy_resource.reindex }.not_to raise_error
  end

  describe 'to_solr' do
    subject(:document) do
      bibliograpy_resource.document_builder.to_solr.first
    end

    it 'has a doc id' do
      expect(document['id']).to eq ['Barb_gr_252']
    end

    it 'has a resource type' do
      expect(document['resource_type_ssim']).to eq ['Manuscript']
    end

    it 'has a title' do
      expect(document['full_title_tesim']).to eq ['Barb.gr.252']
    end

    it 'has all titles' do
      expect(document['title_tesim']).to eq [
        'Vitae sophistarum', 'Sententiae ad intelligibilia ducentes', 'De abstinentia',
        'Vitae sophistarum (Eunapius Sardianus, 354-420)',
        'Sententiae ad intelligibilia ducentes (Porphyrius Tyrius, 232/233-305?)',
        'De abstinentia (Porphyrius Tyrius, 232/233-305?)'
      ]
    end

    it 'has incipit' do
      expect(document['incipit_tesim']).to be_nil
    end

    it 'has explicit' do
      expect(document['explicit_tesim']).to be_nil
    end

    it 'has date' do
      expect(document['date_ssim']).to eq ['sec. xvi med', 'sec. xvi med (ff. 1-38)', 'anno 1539 (ff. 41-112)']
    end

    it 'has beginning date' do
      expect(document['beginning_date_ssim']).to eq ['1526']
    end

    it 'has ending date' do
      expect(document['ending_date_ssim']).to eq ['1575']
    end

    it 'has dated mss' do
      expect(document['dated_mss_ssim']).to eq ['1539']
    end

    it 'has author' do
      expect(document['author_ssim']).to eq ['Eunapius Sardianus', 'Porphyrius Tyrius', 'Greco']
    end

    it 'has other author' do
      expect(document['other_author_ssim']).to be_nil
    end

    it 'has other name' do
      expect(document['other_name_ssim']).to eq ['Albini, Valeriano']
    end

    it 'has place' do
      expect(document['place_ssim']).to be_nil
    end

    it 'has a language' do
      expect(document['language_ssim']).to eq ['Greco']
      expect(document['language_tesim']).to eq ['Greco']
    end

    it 'has a collection' do
      expect(document['collection_ssim']).to eq ['Barb.gr.']
      expect(document['collection_tesim']).to eq ['Barb.gr.']
    end

    it 'has a watermark' do
      expect(document['watermark_tesim'].first).to include('In prima parte codicis')
    end

    it 'has a colophon' do
      expect(document['colophon_tesim'].first).to include('Ἀδελφὸς Οὐαλεριᾶνος Φορολιβιεὺς')
    end

    it 'has iiif manifest' do
      expect(document['iiif_manifest_url_ssi']).to eq ['https://digi.vatlib.it/iiif/MSS_Barb.gr.252/manifest.json']
    end

    it 'has spotlight data' do
      expect(document).to include :spotlight_resource_id_ssim
    end

    it 'has a summary' do
      expect(document['summary_tesim']).to be_nil
    end

    it 'has a overview' do
      expect(document['overview_tesim']).to eq ['Libellus I.', 'Libellus II.']
    end

    it 'has all of the text' do
      expect(document['all_text_timv']).to include 'console'
    end

    it 'has manuscript-level information' do
      expect(document).to include 'manuscript_alphabet_tesim' => ['Greco.'],
                                  'manuscript_beginning_date_tesim' => ['1526'],
                                  'manuscript_binding_note_tesim' => ['Integumentum membranaceum; in dorso: "Eunapio et Porphyrio greco".'],
                                  'manuscript_binding_tesim' => ['Membr.'],
                                  'manuscript_colophon_tesim' => ['F. 112v, atramento subrubro: Ἀδελφὸς Οὐαλεριᾶνος Φορολιβιεὺς ὁ Ἀλβίνου ταύτην | βίβλον ἐν τῷ μοναστηρίῳ τοῦ ἁγίου Ἀντω|νίου Ἐνέτησιν ἔγραψε, ἔτη το(ῦ) Κ(υρίο)υ ἡμῶν ͵αφλθ´ (manus poster. vertit 1539): v. Vogel-Gardthausen, p. 370.'],
                                  'manuscript_content_tesim' => ['Miscellanea Eunapii atque Porphyrii operum.'],
                                  'manuscript_date_mss_tesim' => ['1539'],
                                  'manuscript_date_tesim' => ['sec. XVI med', 'sec. XVI med (ff. 1-38)', 'anno 1539 (ff. 41-112)'],
                                  'manuscript_decoration_note_tesim' => ['In utraque parte, tituli et litterae initiales annotationesque nonnullae, atramento subrubro.'],
                                  'manuscript_ending_date_tesim' => ['1575'],
                                  'manuscript_extent_tesim' => ['ff. I. 113 (+81. 86. 95)'],
                                  'manuscript_general_note_tesim' => ['Codex efficitur duobus libellis, a totidem librariis fere eadem aetate conscriptis et postea in unum conftatis.', 'F. Ir, nota antiqua "276".', 'F. 1r, alia manu: Εὐναπίου βίοι Φιλοσόφων καὶ Σοφιστῶν | Πορφυρίου τῶν πρὸς τὰ νοητὰ ἀφορμῶν, et eadem manu in margine: "Codex seculi XVI".'],
                                  'manuscript_height_tesim' => ['320'],
                                  'manuscript_language_tesim' => ['Greco.'],
                                  'manuscript_library_tesim' => ['Biblioteca Apostolica Vaticana'],
                                  'manuscript_other_name_tesim' => ['Albini, Valeriano,'],
                                  'manuscript_shelfmark_tesim' => ['Barb.gr.252'],
                                  'manuscript_support_tesim' => ['chart.'],
                                  'manuscript_watermarks_tesim' => ['In prima parte codicis, officinarum chartariarum signa duo: ancora in circulo, stella superposita (cf. Briquet 588) et arcuballista in circulo, lilio superposito (Briquet 761); in secunda parte, signum unicum: sagittae, stella superposita (cf. Briquet 6300).'],
                                  'manuscript_width_tesim' => ['230'],
                                  'manuscript_writing_note_tesim' => ['Prior libellus (ff. 1r-38v) manu <Basilii Valeris seu Varelis> exaratus est. Vacua sunt ff. 1v. 39r-v.']
    end
  end
end
