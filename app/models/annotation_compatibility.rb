##
# Handles the ability to determine an Annotation's manifest uri from
# multiple formats
class AnnotationCompatibility
  attr_reader :data

  # @param [Hash] data
  def initialize(data)
    @data = data
  end

  def manifest_uri
    return unless data['on']

    case data['on']
    when String
      data['on'].gsub(/canvas.*/, 'manifest.json')
    when Array
      data['on'].first['within']['@id']
    end
  end

  def selector
    return unless data['on']

    case data['on']
    when String
      {
        'value' => data['on'],
        '@type' => 'oa:FragmentSelector'
      }
    when Array
      data['on'].first['selector']['default']
    end
  end
end
