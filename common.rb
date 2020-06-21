# coding: utf-8

require 'yaml'
require 'twitter'

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
