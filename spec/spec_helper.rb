# encoding: utf-8

if RUBY_ENGINE == 'rbx'
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'rom-mongo'

root = Pathname(__FILE__).dirname

Dir[root.join('shared/*.rb').to_s].each { |f| require f }

require 'dry-types'
Dry::Types.register('bson.object_id', Dry::Types::Definition.new(BSON::ObjectId).constructor { |bson_id|
  raise TypeError.new("expected a BSON::ObjectId") unless bson_id.kind_of?(BSON::ObjectId)
  bson_id
})

RSpec.configure do |config|
  config.before do
    @constants = Object.constants
  end

  config.after do
    added_constants = Object.constants - @constants
    added_constants.each { |name| Object.send(:remove_const, name) }
  end
end
