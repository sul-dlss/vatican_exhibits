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
        unless annotation.uuid.match?(/[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/)
          uuid = SecureRandom.uuid
          annotation.uuid = uuid
          data['@id'] = uuid
        end

        # Remediate bounding box coordinates for SVG-only shapes
        if !data['on'].is_a?(String) &&
           data['on'].first['selector']['default']['@type'] == 'oa:FragmentSelector' &&
           data['on'].first['selector']['default']['value'] == 'xywh=0,0,0,0' &&
           data['on'].first['selector']['item']['@type'] == 'oa:SvgSelector'

          svg = data['on'].first['selector']['item']['value']
          svg_data = Nokogiri::XML(svg)
          path = svg_data.xpath('//svg:path/@d', svg: 'http://www.w3.org/2000/svg').first.to_s

          if path
            instructions = path.scan(/([a-zA-Z])([^a-zA-Z]+)/)
            abs_coords = []

            instructions.each_with_object(abs_coords) do |(cmd, coords_str)|
              coords = coords_str.split(' ').first.split(',').map(&:to_f)
              last_coord = abs_coords.last

              # uppercase commands are absolute movement; lower case are relative
              case cmd
              when 'M', 'L', 'C'
                abs_coords << coords
              when 'l', 'c'
                abs_coords << [last_coord[0] + coords[0], last_coord[1] + coords[1]]
              when 'H'
                abs_coords << [coords[0], last_coord[1]]
              when 'h'
                abs_coords << [last_coord[0] + coords[0], last_coord[1]]
              when 'V'
                abs_coords << [last_coord[0], coords[1]]
              when 'v'
                abs_coords << [last_coord[0], last_coord[1] + coords[0]]
              when 'Z', 'z'
                abs_coords << abs_coords.first
              end
            end

            x1 = abs_coords.min_by(&:first)
            y1 = abs_coords.min_by(&:last)
            x2 = abs_coords.max_by(&:first)
            y2 = abs_coords.max_by(&:last)

            bounding_box = "xywh=#{x1.first.round},#{y1.last.round},#{(x2.first - x1.first).ceil},#{(y2.last - y1.last).ceil}"
            data['on'].first['selector']['default']['value'] = bounding_box
          end
        end

        # We don't want to double encode JSON data here
        annotation.data = data.is_a?(Hash) ? data.to_json : data
        annotation.save!
      end
    end
    puts 'Finished remediating annotations.'
  end
end
