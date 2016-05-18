require 'spec_helper'

describe ROM::Mongo::Dataset do

  let(:gateway) { ROM::Mongo::Gateway.new('mongodb://127.0.0.1:27017/test') }
  let(:users) { gateway.dataset('users') }

  describe 'find' do
    it 'works with criteria' do
      dataset = users.find(name: /alice/)
      expect(dataset.selector).to eq('name' => /alice/)
    end

    it 'works with a block' do
      dataset = users.find { |c| c.where(name: /alice/) }
      expect(dataset.selector).to eq('name' => /alice/)
    end

    it 'it uses instance_eval when block has no params' do
      dataset = users.find { where(name: /alice/).in(groups: %w(admin)) }
      expect(dataset.selector).to eq('name' => /alice/, 'groups' => {'$in' => ['admin']})
    end
  end


  describe 'dataset query DSL chaining' do
    it 'support chaining DSL methods' do
      dataset = users.where(name: /alice/).in(groups: ['admin'])

      expect(users.selector).to eq({})
      expect(dataset).to be_a(ROM::Mongo::Dataset)

      expected_selector = {'name' => /alice/, 'groups' => {'$in' => ['admin']}}
      expect(dataset.selector).to eq(expected_selector)
    end

    it 'returns a new dataset when query DSL method is used' do
      expect(users.selector).to eq({})
      dataset = users.where(name: /alice/)
      expect(users.selector).to eq({})
      expect(dataset.selector).to eq('name' => /alice/)
    end
  end
end