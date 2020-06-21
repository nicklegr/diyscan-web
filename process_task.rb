# coding: utf-8

require 'twitter'
require_relative 'common'
require_relative 'db'
require_relative 'http'

loop do
  task = Task.where(status: "waiting").asc(:requested_at).first
  if task
    puts "start: #{task.movie_url}"
    STDOUT.flush

    task.status = "processing"
    task.save!

    begin
      ocr_result = MyHttp.get(ENV["WORKER_URL"], {}, { "url" => task.movie_url })
    rescue Net::HTTPClientException => e
      # 404 Not Foundなど
      task.status = "error"
      task.finished_at = Time.now
      task.error_message = e.message
      task.save!
      puts "error: #{e.message}"
    rescue SocketError => e
      task.status = "waiting"
      task.save!
      puts "worker error: #{e.message}"
    else
      # 成功
      task.status = "done"
      task.finished_at = Time.now
      task.ocr_result = ocr_result
      task.save!

      result_key = SecureRandom.urlsafe_base64(8)
      Result.create!(
        key: result_key,
        twitter_user_id: task.twitter_user_id,
        twitter_screen_name: task.twitter_screen_name,
        twitter_status_id: task.twitter_status_id,
        twitter_raw_tweet: task.twitter_raw_tweet,
        movie_url: task.movie_url,
        ocr_result: task.ocr_result,
        )

      reply_message = "@#{task.twitter_screen_name} 認識が終わりました！ #{ENV["WEB_BASE_URL"]}/result/#{result_key}"
      client = twitter_client
      client.update(reply_message, in_reply_to_status_id: task.twitter_status_id)

      puts "done: key: #{result_key}"
    end

    STDOUT.flush
  end

  sleep(3)
end
