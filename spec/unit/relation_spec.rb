require 'spec_helper'

describe ROM::Mongo::Relation do
  include_context('database setup')
  before {
    setup.use(:macros)
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
end