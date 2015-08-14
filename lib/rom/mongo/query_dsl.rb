module ROM
  module Mongo
    module QueryDSL
      def where(doc)
        dataset(criteria.where(doc))
      end

      def only(fields)
        dataset(criteria.only(fields))
      end

      def without(fields)
        dataset(criteria.without(fields))
      end

      def limit(limit)
        dataset(criteria.limit(limit))
      end

      def skip(value)
        dataset(criteria.skip(value))
      end
    end
  end
end