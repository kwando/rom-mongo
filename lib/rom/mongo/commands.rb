require 'bson'

require 'rom/commands'

module ROM
  module Mongo
    module Commands
      class Create < ROM::Commands::Create
        def collection
          relation.dataset
        end

        def execute(document)
          collection.insert(input[document])
          [document]
        end
      end

      class Update < ROM::Commands::Update
        def collection
          relation.dataset
        end

        def execute(document)
          collection.update('$set' => input[document])
          collection.to_a
        end
      end

      class Delete < ROM::Commands::Delete
        def execute
          removed = relation.to_a
          relation.dataset.delete
          removed
        end
      end
    end
  end
end
