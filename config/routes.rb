Rails.application.routes.draw do

  mount Blacklight::Oembed::Engine, at: 'oembed'
  root to: 'spotlight/exhibits#index'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  mount Riiif::Engine => '/images', as: 'riiif'
  mount Spotlight::Engine, at: '/'
  mount Blacklight::Engine, at: '/'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
