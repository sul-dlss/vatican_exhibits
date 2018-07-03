# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManuscriptMetadataPresenter do
  let(:presenter) { described_class.new(context: context, document: document) }

  let(:context) do
    instance_double(
      'ViewContext',
      document_show_fields: document_show_fields,
      should_render_show_field?: should_render_show_field
    )
  end
  let(:document) { SolrDocument.new }
  let(:document_show_fields) { {} }
  let(:should_render_show_field) { false }
  let(:general_field) { instance_double('Field', section: :general) }
  let(:description_field) { instance_double('Field', section: nil) }

  describe 'section accessors' do
    it 'has a general, description, and admin sections' do
      expect(presenter.general_section).to be_a ManuscriptMetadataPresenter::Section
      expect(presenter.description_section).to be_a ManuscriptMetadataPresenter::Section
      expect(presenter.admin_section).to be_a ManuscriptMetadataPresenter::Section
    end
  end

  describe ManuscriptMetadataPresenter::Section do
    subject(:section) { described_class.new(context: context, document: document, type: type) }

    let(:type) { :general }

    describe '#render?' do
      context 'when there are fields' do
        let(:document_show_fields) { { field1: general_field } }
        let(:should_render_show_field) { true }

        it { expect(section.render?).to be true }
      end

      context 'when there are no fields' do
        it { expect(section.render?).to be false }
      end
    end

    describe '#fields' do
      let(:document_show_fields) { { gen_field: general_field, desc_field: description_field } }

      context 'when the description section' do
        let(:type) { :description }
        let(:should_render_show_field) { true }

        it 'is an array of the fields w/o a section' do
          expect(section.fields.values.length).to eq 1
          expect(section.fields.values.first.section).to be_nil
        end
      end

      context 'when another section' do
        let(:should_render_show_field) { true }

        it 'is an array of fields based on the given section' do
          expect(section.fields.values.length).to eq 1
          expect(section.fields.values.first.section).to eq :general
        end
      end

      describe 'when the field is not configured to display' do
        it 'is not returned' do
          expect(section.fields).to be_blank
        end
      end
    end

    context 'when type is description' do
      let(:type) { :description }

      it 'has a type of nil (since it is the default section)' do
        expect(section.send(:type)).to be_nil
      end
    end

    context 'when type is not description' do
      it 'is the passed in type' do
        expect(section.send(:type)).to be :general
      end
    end
  end
end
