Rails.application.routes.draw do
  mount Annotot::Engine => '/'
  authenticate :user, lambda { |u| u.superadmin? } do
    require 'sidekiq/web'
    Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]
    mount Sidekiq::Web => '/sidekiq'
  end
  mount OkComputer::Engine, at: "/status"
  scope '(:locale)', locale: Regexp.union(Spotlight::Engine.config.i18n_locales.keys.map(&:to_s)), defaults: { locale: nil } do
    resources :mirador, only: [:index]
    mount Blacklight::Oembed::Engine, at: 'oembed'
    mount Riiif::Engine => '/images', as: 'riiif'
    root to: 'spotlight/exhibits#index'
  #  root to: "catalog#index" # replaced by spotlight root path
    concern :searchable, Blacklight::Routes::Searchable.new

    resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
      concerns :searchable
    end
    devise_for :users
    concern :exportable, Blacklight::Routes::Exportable.new

    resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
      concerns :exportable
    end

    resources :exhibits, path: '/', only: [] do
      resource :vatican_iiif_resources, only: [:create, :update]
    end

    resources :bookmarks do
      concerns :exportable

      collection do
        delete 'clear'
      end
    end
  end

  Blacklight::Engine.routes.default_scope = { path: "(:locale)", locale: Regexp.union(Spotlight::Engine.config.i18n_locales.keys.map(&:to_s)), module: 'blacklight', defaults: { locale: nil } }
  mount Blacklight::Engine => '/'

  Spotlight::Engine.routes.default_scope = { path: "(:locale)", locale: Regexp.union(Spotlight::Engine.config.i18n_locales.keys.map(&:to_s)), module: 'spotlight', defaults: { locale: nil } }
  mount Spotlight::Engine, at: '/'

  mount MiradorRails::Engine, at: MiradorRails::Engine.locales_mount_path
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
