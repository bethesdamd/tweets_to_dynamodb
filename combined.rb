# Experiments with Amazon API to Dynamo 
# July 2014
# AWS api info from: http://docs.aws.amazon.com/AWSRubySDK/latest/frames.html
# Twitter api info from: https://github.com/sferik/twitter. Experiments getting tweets

require 'json' 
require 'awesome_print'
require 'AWS'
require 'twitter'
require 'digest'
$LOAD_PATH << '.'
require "myaws"

puts "This code requires that the following env variables are set:"
puts "AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, TWITTER_CONSUMER_SECRET,TWITTER_ACCESS_TOKEN_SECRET"

dynamo_db = Myaws.get_client

@md5 = Digest::MD5.new

=begin
table = dynamo_db.tables.create(
  "MyTable3", 10, 5,
  :hash_key => { :id => :string }
)
sleep 1 while table.status == :creating
=end

@table = dynamo_db.tables['MyTable3']
@table.load_schema
# item = @table.items.create('id' => "12345")

=begin
item = table.items.put(:id => "abc123")
item.hash_value # => "abc123"
item.attributes.set(
  :colors => ["red", "blue"],
  :numbers => [12, 24]
)
=end 

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "KJLgdA9f30mfNrTymM7L8Cwo0"
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = "508863794-uLjoCIbllI9OvivoPr93p2YMcXpiCzMCbphjZLop"
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

client.search("soccer lang=en").take(10).each_with_index do |tweet, i|
  # puts tweet.user_mentions.to_s
  # puts tweet.uris.to_s
  # puts tweet.attrs  #  this is the json metadata for the tweet, has lots of good stuff in it
  puts i.to_s + "  ---------------------------------------------------------------"
  txt = tweet.text
  a = tweet.attrs
  user = a[:user]
  entities = a[:entities]
  # ap a  # Awesome Print
  puts a[:created_at]
  tweet_id = a[:id_str]
  screen_name = user[:screen_name]
  user_name = user[:name]  # user's real name
  symbols = a[:symbols]
  user_mentions = entities[:user_mentions]
  friends_count = user[:friends_count]
  puts "friends count: " + friends_count.to_s + ", user mentions count: " + user_mentions.size.to_s
  @md5.update txt
  hsh = @md5.hexdigest
  puts "id: " + tweet_id
  puts txt

  item = @table.items.create(:id => tweet_id)
  item.attributes.set(
  	:tweet_text => "foo" # SerializationException (doesn't happen with 'foo') looks like a UTF/foreign language thing
  	)
end



