# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

data = JSON.parse(File.read(Rails.root + 'db/pathways.json'))

data['pathways'].each do |pathway|
  exhibit = Spotlight::Exhibit.create_with(title: pathway['name']).find_or_create_by(slug: pathway['name'])
  iiif_urls = pathway['manuscripts'].map { |shelfmark| Settings.vatican_iiif_resource.iiif_template_url.gsub('{shelfmark}', shelfmark) }
  VaticanIiifResource.instance(exhibit).update(iiif_url_list: iiif_urls.join("\n"))

  exhibit.custom_fields.create(field: Settings.curatorial_narrative.field)
end
