module Macros
  # General helpers for any traject mappings, stolen originally from DLME
  module General
    def accumulate(&block)
      lambda do |record, accumulator, context|
        Array(block.call(record, context)).each do |v|
          accumulator << v if v.present?
        end
      end
    end
  end
end
