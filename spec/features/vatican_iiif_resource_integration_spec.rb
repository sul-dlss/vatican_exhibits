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

    before do
      allow(IndexAnnotationsForCanvasJob).to receive(:perform_later)
    end

    it 'triggers annotation indexing for the canvas' do
      document

      expect(IndexAnnotationsForCanvasJob).to have_received(:perform_later).with(/canvas/).exactly(246).times
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
      expect(document['author_ssim']).to eq [
        'Eunapius Sardianus, 354-420 [internal]',
        'Porphyrius Tyrius, 232/233-305? [internal]'
      ]
    end

    it 'has other author' do
      expect(document['other_author_ssim']).to be_nil
    end

    it 'has other name' do
      expect(document['other_name_ssim']).to eq ['Albini, Valeriano, sac., f. 1528-1545 [person]']
      expect(document['other_name_and_role_ssim']).to eq ['Albini, Valeriano [scribe]']
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

    it 'has the TEI' do
      expect(document['tei_ss']).to include(/TEI.2/)
    end

    it 'has manuscript-level information' do
      expect(document).to include 'ms_alphabet_ssim' => ['Greco.'],
                                  'ms_beginning_date_tesim' => ['1526'],
                                  'ms_binding_note_tesim' => ['Integumentum membranaceum; in dorso: "Eunapio et Porphyrio greco".'],
                                  'ms_binding_tesim' => ['Membr.'],
                                  'ms_colophon_tesim' => ['F. 112v, atramento subrubro: Ἀδελφὸς Οὐαλεριᾶνος Φορολιβιεὺς ὁ Ἀλβίνου ταύτην | βίβλον ἐν τῷ μοναστηρίῳ τοῦ ἁγίου Ἀντω|νίου Ἐνέτησιν ἔγραψε, ἔτη το(ῦ) Κ(υρίο)υ ἡμῶν ͵αφλθ´ (manus poster. vertit 1539): v. Vogel-Gardthausen, p. 370.'],
                                  'ms_content_tesim' => ['Miscellanea Eunapii atque Porphyrii operum.'],
                                  'ms_date_mss_ssim' => ['1539'],
                                  'ms_date_ssim' => ['sec. XVI med', 'sec. XVI med (ff. 1-38)', 'anno 1539 (ff. 41-112)'],
                                  'ms_decoration_note_tesim' => ['In utraque parte, tituli et litterae initiales annotationesque nonnullae, atramento subrubro.'],
                                  'ms_ending_date_tesim' => ['1575'],
                                  'ms_extent_tesim' => ['ff. I. 113 (+81. 86. 95)'],
                                  'ms_general_note_tesim' => ['Codex efficitur duobus libellis, a totidem librariis fere eadem aetate conscriptis et postea in unum conftatis.', 'F. Ir, nota antiqua "276".', 'F. 1r, alia manu: Εὐναπίου βίοι Φιλοσόφων καὶ Σοφιστῶν | Πορφυρίου τῶν πρὸς τὰ νοητὰ ἀφορμῶν, et eadem manu in margine: "Codex seculi XVI".'],
                                  'ms_height_tesim' => ['320'],
                                  'ms_language_ssim' => ['Greco.'],
                                  'ms_library_tesim' => ['Biblioteca Apostolica Vaticana'],
                                  'ms_other_name_tesim' => ['Albini, Valeriano, sac., f. 1528-1545 [person]'],
                                  'ms_shelfmark_tesim' => ['Barb.gr.252'],
                                  'ms_support_tesim' => ['chart.'],
                                  'ms_watermarks_tesim' => ['In prima parte codicis, officinarum chartariarum signa duo: ancora in circulo, stella superposita (cf. Briquet 588) et arcuballista in circulo, lilio superposito (Briquet 761); in secunda parte, signum unicum: sagittae, stella superposita (cf. Briquet 6300).'],
                                  'ms_width_tesim' => ['230'],
                                  'ms_writing_note_tesim' => ['Prior libellus (ff. 1r-38v) manu <Basilii Valeris seu Varelis> exaratus est. Vacua sunt ff. 1v. 39r-v.']
    end

    it 'has parts' do
      expect(document['parts_ssm'].length).to eq 3
      data = document['parts_ssm'].map { |x| JSON.parse(x) }
      expect(data).to include hash_including(
        'ms_overview_tesim' => ['Libellus I.'],
        'ms_locus_tesim' => ['1r-38v'],
        'ms_author_header_tesim' => ['Eunapius Sardianus,'],
        'ms_author_tesim' => ['Eunapius Sardianus, 354-420 [internal]'],
        'ms_supplied_title_tesim' => ['Vitae sophistarum'],
        'ms_uniform_title_tesim' => ['Vitae sophistarum (Eunapius Sardianus, 354-420)'],
        'ms_language_ssim' => ['Greco.'],
        'ms_alphabet_ssim' => ['Greco.'],
        'ms_source_of_information_tesim' => ['J. Mogenet, Codices Barberiniani Graeci, in Bibliotheca Vaticana 1989, v. 2, p. 100.']
      )
    end
    context 'with more complex author display' do
      subject(:document) do
        bibliograpy_resource.document_builder.to_solr.first
      end

      let(:bibliograpy_resource) do
        VaticanIiifResource.new(
          iiif_url_list: 'https://digi.vatlib.it/iiif/MSS_Ott.gr.85/manifest.json',
          exhibit: exhibit
        )
      end

      before do
        stub_request(:get, 'https://digi.vatlib.it/iiif/MSS_Ott.gr.85/manifest.json')
          .to_return(body: stubbed_manifest('MSS_Ott.gr.85.json'))
        stub_request(:get, 'https://digi.vatlib.it/tei/Ott.gr.85.xml')
          .to_return(body: stubbed_tei('Ott.gr.85.xml'))
        allow(IndexAnnotationsForCanvasJob).to receive(:perform_later)
      end

      it 'works with present and missing values' do
        expect(document['author_ssim']).to include(
          'Leontius Constantinopolitanus, sec. VII [internal]',
          'Athanasius, s., patriarca di Alessandria, 292-373. Opere spurie e dubbie [internal]',
          'Iohannes Chrysostomus, s., patriarca di Costantinopoli, 347-407. Opere spurie e dubbie [internal]'
        )
        expect(document['ms_other_name_tesim']).to include(
          'Altemps (famiglia) [person]'
        )
      end
    end

    context 'with other author and other name' do
      subject(:document) do
        bibliograpy_resource.document_builder.to_solr.first
      end

      let(:bibliograpy_resource) do
        VaticanIiifResource.new(
          iiif_url_list: 'https://digi.vatlib.it/iiif/MSS_Vat.lat.3195/manifest.json',
          exhibit: exhibit
        )
      end

      before do
        stub_request(:get, 'https://digi.vatlib.it/iiif/MSS_Vat.lat.3195/manifest.json')
          .to_return(body: stubbed_manifest('MSS_Vat.lat.3195.json'))
        stub_request(:get, 'https://digi.vatlib.it/tei/Vat.lat.3195.xml')
          .to_return(body: stubbed_tei('Vat.lat.3195.xml'))
        allow(IndexAnnotationsForCanvasJob).to receive(:perform_later)
      end

      it 'works with present and missing values' do
        expect(document['other_author_ssim']).to include(
          'Petrarca, Francesco, 1304-1374 [internal]'
        )
        expect(document['ms_other_author_tesim']).to include(
          'Petrarca, Francesco, 1304-1374 [internal]'
        )
        expect(document['ms_other_name_tesim']).to include(
          'Malpaghini, Giovanni, n. c. 1346-m. c. 1417 [person]',
          'Bembo, Pietro, card., 1470-1547 [person]'
        )
      end
    end
  end
end
