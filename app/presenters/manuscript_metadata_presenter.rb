# frozen_string_literal: true

##
# A simple presenter class that abstracts the logic of rendering sections of metadata
# The sections are simple groupings of metadata based on configuration, and structured
# in the UI with a heading and a definition list.
class ManuscriptMetadataPresenter
  def initialize(context:, document:)
    @context = context
    @document = document
  end

  def general_section
    @general_section ||= Section.new(
      context: context,
      document: document,
      type: :general
    )
  end

  def description_section
    @description_section ||= Section.new(
      context: context,
      document: document,
      type: :description
    )
  end

  def admin_section
    @admin_section ||= Section.new(
      context: context,
      document: document,
      type: :administrative
    )
  end

  private

  attr_reader :context, :document

  ##
  # A class to represent a section of metadata based on the provided type
  class Section
    delegate :document_show_fields,
             :should_render_show_field?,
             to: :context

    attr_reader :context, :document
    def initialize(context:, document:, type:)
      @context = context
      @document = document
      @type = type.to_sym
    end

    def render?
      fields.any?
    end

    def fields
      document_show_fields(document).select do |_, field|
        field.section == type && should_render_show_field?(document, field)
      end
    end

    private

    def type
      return nil if @type == :description

      @type
    end
  end
end
