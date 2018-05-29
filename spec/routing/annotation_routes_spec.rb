require 'rails_helper'

RSpec.describe 'Annotation Routing', type: :routing do
  it '#index' do
    expect(get: '/annotations').to route_to(
      'controller': 'annotot/annotations',
      'action': 'index',
      'format': :json
    )
  end
end
