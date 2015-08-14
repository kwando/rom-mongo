require 'origin'
require 'rom/mongo/query_dsl'

module ROM
  module Mongo
    class Dataset
      class Criteria
        include Origin::Queryable

        def to_criteria
          self
        end
      end

      def initialize(collection, criteria = Criteria.new)
        @collection = collection
        @criteria = criteria
      end

      attr_reader :collection

      attr_reader :criteria

      def find(criteria = {}, &block)
        if block_given?
          if block.arity == 1
            criteria = block.call(@criteria)
          else
            criteria = @criteria.instance_eval(&block)
          end

          if !criteria.respond_to?(:to_criteria)
            raise TypeError.new('expecting block to return an object responding to #to_criteria')
          end
          criteria = criteria.to_criteria
        else
          criteria = Criteria.new.where(criteria)
        end
        Dataset.new(collection, criteria)
      end

      def to_a
        view.to_a
      end

      # @api private
      def each
        view.each { |doc| yield(doc) }
      end

      def insert(data)
        collection.insert_one(data)
      end

      def update_all(attributes)
        view.update_many(attributes)
      end

      def remove_all
        view.delete_many
      end

      def selector
        criteria.selector
      end

      private

      def view
        with_options(collection.find(criteria.selector), criteria.options)
      end

      def dataset(criteria)
        Dataset.new(collection, criteria)
      end

      # Applies given options to the view
      #
      # @api private
      def with_options(view, options)
        map = {fields: :projection}
        options.each do |option, value|
          option = map.fetch(option, option)
          view = view.send(option, value) if view.respond_to?(option)
        end
        view
      end
    end
  end
end
ROM::Mongo::QueryDSL.setup!
