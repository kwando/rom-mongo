module ROM
  module Mongo
    class Relation < ROM::Relation
      adapter(:mongo)
      forward :insert, :find, :delete, :update

      def to_criteria
        dataset.criteria
      end

      def empty?
        dataset.count == 0
      end
    end
  end
end
