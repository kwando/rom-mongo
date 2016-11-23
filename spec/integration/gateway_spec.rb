require 'spec_helper'

require 'virtus'
require 'dry-types'
require 'dry-struct'

describe 'Mongo gateway' do
  include_context('database setup')

  before do
    setup.relation(:users) do
      def by_name(name)
        find(name: name)
      end

      def all
        find
      end
    end

    setup.commands(:users) do
      define(:create) {
        input(Dry::Types['hash'].permissive(
            name:  'strict.string',
            email: 'strict.string'
        ))
      }
      define(:update)
      define(:delete)
    end

    user_model = Class.new(Dry::Struct) do
      attribute :id, 'coercible.string'
      attribute :name, 'strict.string'
      attribute :email, 'strict.string'
    end

    setup.mappers do
      define(:users) do
        model(user_model)

        register_as :model

        attribute :id, from: '_id'
        attribute :name, from: 'name'
        attribute :email, from: 'email'
      end
    end

    users.insert(name: 'Jane', email: 'jane@doe.org')
    users.insert(name: 'Joe', email: 'joe@doe.org')
  end


  describe 'env#relation' do
    it 'returns mapped object' do
      jane = users.as(:model).by_name('Jane').one!

      expect(jane.id)
          .to eql(rom.relation(:users) { |r| r.find(name: 'Jane') }.one['_id'].to_s)
      expect(jane.name).to eql('Jane')
      expect(jane.email).to eql('jane@doe.org')
    end
  end

  describe 'gateway#dataset?' do
    it 'returns true if a collection exists' do
      expect(gateway.dataset?(:users)).to be(true)
    end

    it 'returns false if a does not collection exist' do
      expect(gateway.dataset?(:not_here)).to be(false)
    end
  end

  describe 'commands' do
    let(:commands) { rom.command(:users) }

    describe 'create' do
      it 'inserts a document into collection' do
        id = BSON::ObjectId.new

        result = commands.try do
          commands.create.call(_id: id, name: 'joe', email: 'joe@doe.org')
        end

        expect(result)
            .to match_array([{_id: id, name: 'joe', email: 'joe@doe.org'}])
      end
    end

    describe 'update' do
      it 'updates a document in the collection' do
        jane = rom.relation(:users).as(:model).by_name('Jane').one!

        result = commands.try do
          commands.update.by_name('Jane').call(email: 'jane.doe@test.com')
        end

        expect(result).to match_array(
                              [{'_id'   => BSON::ObjectId.from_string(jane.id),
                                'name'  => 'Jane',
                                'email' => 'jane.doe@test.com'}]
                          )
      end
    end

    describe 'delete' do
      it 'deletes documents from the collection' do
        jane = rom.relation(:users).as(:model).by_name('Jane').one!
        joe  = rom.relation(:users).as(:model).by_name('Joe').one!

        result = commands.try { commands.delete.by_name('Joe') }

        expect(result).to match_array(
                              [{'_id'   => BSON::ObjectId.from_string(joe.id),
                                'name'  => 'Joe',
                                'email' => 'joe@doe.org'}]
                          )

        expect(rom.relation(:users).as(:model).all).to match_array([jane])
      end
    end
  end
end
