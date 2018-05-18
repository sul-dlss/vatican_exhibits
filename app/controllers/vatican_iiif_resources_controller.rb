##
# Controller managing VaticanIiifResource operations
class VaticanIiifResourcesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  before_action :build_resource
  authorize_resource

  def create
    @resource.update(resource_params)

    if @resource.save_and_index
      redirect_to spotlight.admin_exhibit_catalog_path(current_exhibit),
                  notice: I18n.t('vatican_iiif_resources.create.notice')
    else
      redirect_to spotlight.new_exhibit_resource_path(current_exhibit),
                  notice: I18n.t('vatican_iiif_resources.create.error')
    end
  end

  alias update create

  private

  def build_resource
    @resource = VaticanIiifResource.instance(current_exhibit)
  end

  def resource_params
    params.require(:vatican_iiif_resource).permit(:iiif_url_list, :tei_url)
  end
end
