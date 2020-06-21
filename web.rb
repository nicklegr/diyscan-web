# coding: utf-8

require 'pp'
require 'json'
require 'sinatra'
require 'sinatra/url_for'
require 'haml'
require_relative 'db'
require_relative 'build_recipe_list'

get '/' do
  "hello, world!"
end

get '/result/:key' do
  result = Results.where(key: params[:key]).first
  if result
    parser = ResultParser.new

    content_type "text/plain"
    parser.parse(result.ocr_result).join("\n")
  else
    404
  end
end
