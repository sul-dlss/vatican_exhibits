require 'rails_helper'

RSpec.describe Annotot::Annotation do
  it 'fires off an indexing job after it is updated' do
    ActiveJob::Base.queue_adapter = :test
    expect { described_class.create! uuid: 'x', canvas: 'y' }.to have_enqueued_job(IndexAnnotationJob)
  end
end
