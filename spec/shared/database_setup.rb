shared_context 'database setup' do
  subject(:rom) { ROM.container(setup) }

  let(:setup) { ROM::Configuration.new(:mongo, 'mongodb://127.0.0.1:27017/test') }
  let(:gateway) { rom.gateways[:default] }

  after do
    gateway.connection.database.drop
  end

  let(:users) { rom.relation(:users) }
end