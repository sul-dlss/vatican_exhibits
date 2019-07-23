desc 'Reindex all exhibit items synchronously'
task reindex_now: :environment do
  Spotlight::Exhibit.find_each do |e|
    Spotlight::ReindexJob.perform_now(e)
  end
end

desc 'Reindex all exhibit items asynchronously'
task reindex: :environment do
  Spotlight::Exhibit.find_each do |e|
    Spotlight::ReindexJob.perform_later(e)
  end
end
