require 'spec_helper'
describe ROM::Mongo::Dataset do
  let(:gateway) { ROM::Mongo::Gateway.new('127.0.0.1:27017/rom-dataset-test') }

  let(:dataset) { gateway.dataset(:users) }

  describe '#initialize' do
    it 'blows up when not given an criteria object' do
      collection = gateway.dataset(:users).collection
      expect(collection).to be_a(Mongo::Collection)
      expect { ROM::Mongo::Dataset.new(collection) }.not_to raise_error
      expect { ROM::Mongo::Dataset.new(collection, "I'm not a criteria object") }.to raise_error
    end
  end

  describe 'insert' do
    it 'returns the correct type' do
      result = dataset.insert(username: 'kwando')

      expect(result).to be_a(Mongo::Operation::Result)
    end
  end

  describe 'updating records' do
    before { dataset.collection.drop }

    it 'works' do
      expect(dataset).to be_empty

      dataset.insert(username: 'alice', age: 28)
      dataset.insert(username: 'bob', age: 25)

    end
  end

  describe 'empty?' do
    before { dataset.collection.drop }

    it 'returns true when collection is empty' do
      expect(dataset).to be_empty
    end

    it 'it returns false when collection is not empty?' do
      dataset.collection.insert_one(username: 'alice')

      expect(dataset).not_to be_empty
    end
  end

  describe 'count' do
    before { dataset.collection.drop }

    it 'returns 0 when the collection is empty' do
      expect(dataset.count).to eq(0)
    end

    it 'returns this correct count for collection' do
      dataset.collection.insert_one(username: 'alice')

      expect(dataset.count).to eq(1)
    end

    it 'applies the criteria before counting' do
      dataset.collection.insert_many([{username: 'alice'}, {username: 'bob'}])
      expect(dataset.count).to eq(2)
      expect(dataset.find(username: 'alice').count).to eq(1)
    end
  end


  describe 'update_all' do
    before {
      dataset.collection.drop
      dataset.insert(username: 'alice', age: 22)
      dataset.insert(username: 'bob', age: 22)
      dataset.insert(username: 'eve', age: 40)
    }

    it 'updates all objects in the collection' do
      dataset.update_all(:$set => {age: 42})
      expect(dataset.find(age: 42).count).to eq(3)
    end

    it 'only updates objects that matches the criteria' do
      dataset.find(age: 22).update_all(:$set => {age: 42})

      expect(dataset.find(age: 22)).to be_empty
      expect(dataset.find(age: 42).count).to eq(2)
    end
  end
end