require 'spec_helper'

describe ROM::Mongo::Relation do
  include_context('database setup')
  before {
    setup.relation(:users)

    users.insert(name: 'Hannes')
    users.insert(name: 'Kalle')
  }

  it 'works' do
    relation = users.where(name: 'Hannes').limit(2)
    criteria = relation.to_criteria

    expect(criteria.selector).to eq({'name' => 'Hannes'})

    result = relation.to_a
    expect(result).to be_a(Array)
    expect(result).not_to be_empty
  end

  describe 'empty?' do
    it 'works' do
      expect(users.where(name: 'Hannes')).not_to be_empty
      expect(users.where(name: 'Unknown')).to be_empty
    end
  end

  describe 'update' do
    it 'only updates filtered records' do
      expect(users.where(name: 'Hannes')).not_to be_empty
      result = users.where(name: 'Hannes').update('$set' => {name: 'Nisse'})
      expect(users.where(name: 'Hannes')).to be_empty
    end
  end
end