desc 'Reindex all exhibit items'
task reindex: :environment do
  Spotlight::Exhibit.find_each do |e|
    Spotlight::ReindexJob.perform_now(e)
  end
end
