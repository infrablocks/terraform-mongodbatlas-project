require_relative '../mongo_db_atlas_client'

shared_context :mongo_db_atlas do
  let(:mongo_db_atlas_client) { MongoDBAtlasClient.new }
end
