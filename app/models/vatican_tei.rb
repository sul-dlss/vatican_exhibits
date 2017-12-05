# frozen_string_literal: true

# Model to represent the TEI of a Vatican object
class VaticanTei < Spotlight::Resource
  self.document_builder_class = VaticanTeiResourceBuilder
  validate :valid_syntax?
  validate :valid_schema?

  store :data, accessors: %i[blob metadata]

  def xml
    @xml ||= Nokogiri::XML.parse(blob)
  end

  def metadata
    super || {}
  end

  private

  def valid_syntax?
    xml
    true
  rescue Nokogiri::XML::SyntaxError
    errors.add(:xml, 'Invalid XML')
  end

  def valid_schema?
    schema_errors = xml.validate

    return unless schema_errors

    schema_errors.each do |e|
      errors.add(:xml, e)
    end
  end
end
