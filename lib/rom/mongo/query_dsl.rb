module ROM
  module Mongo
    module QueryDSL
      [
          :where,
          :only,
          :without,
          :limit,
          :skip,
          :in,
          :all,
          :between,
          :elem_match,
          :exists,
          :gt,
          :gte,
          :lt,
          :lte,
          :max_distance,
          :mod,
          :ne,
          :near,
          :nin,
          :with_size,
          :within_box,
          :within_circle,
          :within_polygon,
          :within_spherical_circle
      ].each do |name|
        define_method(name) do |*args|
          dataset(criteria.send(name, *args))
        end
      end

      def self.setup!
        ROM::Mongo::Relation.forward(*ROM::Mongo::QueryDSL.public_instance_methods(false))
        ROM::Mongo::Dataset.include(ROM::Mongo::QueryDSL)
        self
      end
    end
  end
end