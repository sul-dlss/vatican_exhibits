##
# Mirador controller providing an iframeable Mirador
class MiradorController < ApplicationController
  before_action :set_mirador_params
  layout false

  def index; end

  private

  def set_mirador_params
    @manifest = params.fetch(:manifest, nil)
    @canvas = params.fetch(:canvas, nil)
    @options = params.fetch(:options, nil)
  end
end
