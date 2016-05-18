module ROM
  module Mongo
    class Relation < ROM::Relation
      adapter(:mongo)
      forward :insert, :find

      def to_criteria
        dataset.criteria
      end
    end
  end
end
