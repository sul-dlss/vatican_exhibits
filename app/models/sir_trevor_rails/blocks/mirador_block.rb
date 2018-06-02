module SirTrevorRails
  module Blocks
    ##
    # Mirador viewer block
    class MiradorBlock < SirTrevorRails::Block
      def items
        super.try(:values) || []
      end
    end
  end
end
