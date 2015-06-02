require 'origin'
require 'rom/mongo/query_dsl'

module ROM
  module Mongo
    class Dataset
      class Criteria
        include Origin::Queryable
      end

      def initialize(collection, criteria = Criteria.new)
        raise TypeError.new("exepected a Criteria object but got a #{criteria.class}") unless criteria.kind_of?(Criteria)
        @collection = collection
        @criteria = criteria
      end

      attr_reader :collection
      attr_reader :criteria

      def find(selector = {}, &block)
        unless block.nil?
          new_criteria = criteria.instance_exec(&block)
          raise TypeError.new('return value of the block needs to be a Criteria object') unless criteria.kind_of?(Criteria)
        else
          new_criteria = Criteria.new.where(selector)
        end

        dataset(new_criteria)
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

      def count
        view.count
      end

      def empty?
        count == 0
      end

      def update_all(attributes)
        view.update_many(attributes)
      end

      def update_one(attributes)
        view.update_one(attributes)
      end

      def remove_all
        view.delete_many
      end

      def remove_one
        view.delete_one
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
