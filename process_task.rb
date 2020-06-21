# coding: utf-8

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
      ocr_result = Http.get(ENV["WORKER_URL"], {}, { "url" => task.movie_url })
    rescue Net::HTTPServerException => e
      # 404 Not Foundなど
      task.status = "error"
      task.finished_at = Time.now
      task.error_message = e.message
      task.save!
      puts "error: #{e.message}"
    else
      # 成功
      task.status = "done"
      task.finished_at = Time.now
      task.ocr_result = ocr_result
      task.save!
      puts "done"
    end

    STDOUT.flush
  end

  sleep(3)
end
