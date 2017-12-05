# frozen_string_literal: true

##
# Creating new Vatican TEI items
class VaticanTeisController < Spotlight::ApplicationController
  helper :all

  before_action :authenticate_user!

  load_and_authorize_resource :exhibit, class: Spotlight::Exhibit
  before_action :build_resource, only: :create

  load_and_authorize_resource class: 'VaticanTei',
                              through_association: 'exhibit.resources',
                              instance_name: 'resource',
                              except: :index

  def index
    @resources = VaticanTei.accessible_by(current_ability).order(:url).page params[:page]
  end

  def show
    # default render
  end

  def edit
    # default render
  end

  def destroy
    Blacklight.default_index.connection.delete_by_id @resource.id
    @resource.destroy
    redirect_back(fallback_location: root_path)
  end

  def update
    @resource.attributes = resource_params
    if @resource.save_and_index
      flash[:notice] = t('vatican_teis.update.success')
      redirect_to exhibit_dlme_jsons_path(current_exhibit)
    else
      flash[:error] = t('vatican_teis.update.error')
      render :edit
    end
  end

  def create
    @resource.attributes = resource_params
    if @resource.save_and_index
      flash[:notice] = t('spotlight.resources.upload.success')
      redirect_to spotlight.admin_exhibit_catalog_path(current_exhibit)
    else
      flash[:error] = t('spotlight.resources.upload.error')
      redirect_to spotlight.new_exhibit_resource_path(current_exhibit)
    end
  end

  private

  def build_resource
    @resource ||= VaticanTei.new exhibit: current_exhibit
  end

  def resource_params
    params.require(:vatican_tei).permit(data: [:blob])
  end
end
