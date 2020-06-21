require "mongoid"

class Result
  include Mongoid::Document
  include Mongoid::Timestamps

  field :key, type: String
  field :twitter_user_id, type: Integer
  field :twitter_screen_name, type: String
  field :twitter_status_id, type: Integer
  field :twitter_raw_tweet, type: Hash
  field :movie_url, type: String
  field :ocr_result, type: String

  index({ key: 1 }, { unique: true, name: "key_index" })
end

Mongoid.load!("mongoid.yml", :production)

Result.create_indexes
