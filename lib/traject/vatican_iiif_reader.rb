# Reads in Vatican IIIF records for traject
class VaticanIiifReader
  # @param input_stream [File|IO] At the moment this is only an unvalidated manifest url
  # @param settings [Traject::Indexer::Settings]
  def initialize(input_stream, settings)
    @settings = Traject::Indexer::Settings.new settings
    @input_stream = input_stream
    @data = Array.wrap(input_stream.read)
  end

  attr_reader :data
  delegate :each, :size, to: :data
end
