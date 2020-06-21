# coding: utf-8

require 'pp'
require 'yaml'
require 'securerandom'
require 'twitter'
require_relative 'db'

def twitter_client
  yaml = YAML.load_file('config.yaml')
  client = Twitter::REST::Client.new do |config|
    config.consumer_key = yaml['consumer_key']
    config.consumer_secret = yaml['consumer_secret']
    config.access_token = yaml['oauth_token']
    config.access_token_secret = yaml['oauth_token_secret']
  end
  client
end

client = twitter_client

loop do
  # 最新200件のメンションを取得
  option = { count: 200, tweet_mode: "extended" }
  begin
    client.mentions_timeline(option).each do |tweet|
      # puts "mention: from #{tweet.user.id} (@#{tweet.user.screen_name}): #{tweet.text[0...30]}"
      # pp tweet.to_hash
      next if !tweet.attrs[:extended_entities]

      video = tweet.attrs[:extended_entities][:media].select{|e| e[:type] == "video"}.first
      video_url = video[:video_info][:variants].select{|e| e[:content_type] == "video/mp4"}.max_by{|e| e[:bitrate]}[:url]
      # puts video_url

      if Task.where(twitter_status_id: tweet.id).count == 0
        job_id = SecureRandom.uuid
        puts "add_task: #{job_id}, status_id: #{tweet.id}"
        Task.create!(
          job_id: job_id,
          status: "waiting",
          requested_at: tweet.created_at,
          finished_at: nil,
          movie_url: video_url,
          ocr_result: nil,
          twitter_user_id: tweet.user.id,
          twitter_screen_name: tweet.user.screen_name,
          twitter_status_id: tweet.id,
          twitter_raw_tweet: tweet.to_hash,
          )
      end
    end
  rescue => e
    puts "#{e.class}: #{e.message}"
  end

  STDOUT.flush
  sleep(15)
# sleep(600)
# break
end
