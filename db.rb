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

class Task
  include Mongoid::Document
  include Mongoid::Timestamps

  field :job_id, type: String
  field :status, type: String # waiting, processing, done, error
  field :requested_at, type: Time
  field :finished_at, type: Time

  field :movie_url, type: String
  field :ocr_result, type: String
  field :error_message, type: String

  field :twitter_user_id, type: Integer
  field :twitter_screen_name, type: String
  field :twitter_status_id, type: Integer
  field :twitter_raw_tweet, type: Hash

  index({ twitter_status_id: 1 }, { unique: true, name: "twitter_status_id_index" })
  index({ status: 1 }, { name: "status_index" })
  index({ requested_at: 1 }, { name: "requested_at_index" })
end

Mongoid.load!("mongoid.yml", :production)

Result.create_indexes
Task.create_indexes
