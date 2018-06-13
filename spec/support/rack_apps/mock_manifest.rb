# frozen_string_literal: true

##
# A rack app to return a mocked manifest.
# You can confiugre the MockManifestEndpoint for a parituclar by using the #configure method.
# You can configure the http status code returned, the content type, and the manifest content itself.
# MockManifestEndpoint.configure do |config|
#   config.status = 500
#   config.content = {
#     '@id' => 'http://example.com/manifest.json',
#     label: 'This is the manifest label'
#   }.to_json
# end
# Now you can reference the /mock_manifest relative path when executing
# an action that will trigger an ajax request to the given manifest
class MockManifestEndpoint
  cattr_accessor :content, :content_type, :status

  class << self
    def status
      @@status || 200
    end

    def content_type
      @@content_type || 'application/json'
    end

    def configure
      yield(self) if block_given?
      self
    end
  end

  def call(_env)
    [
      self.class.status,
      { 'content_type' => self.class.content_type },
      [self.class.content]
    ]
  end
end
