namespace :annotations do
  desc 'Remediate annotations'
  task remediate: :environment do
    puts "Updating #{Annotot::Annotation.count} annotations"
    ActiveRecord::Base.transaction do
      Annotot::Annotation.find_each do |annotation|
        print '.'
        # Remove "@context"
        data = JSON.parse(annotation.data)
        data.delete('@context')

        # Update uuid if not a uuid
        unless annotation.uuid.match?(/[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}/)
          uuid = SecureRandom.uuid
          annotation.uuid = uuid
          data['@id'] = uuid
        end
        annotation.data = data.to_json
        annotation.save!
      end
    end
    puts 'Finished remediating annotations.'
  end
end
