#!/usr/bin/env ruby -rubygems

require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'
require 'htmlentities'
require 'newrelic_rpm'

dev_prefix = ENV['RACK_ENV'] == 'development' ? File.expand_path(File.dirname(__FILE__))+'/' : ''
ENV['DATABASE_URL'] ||= "sqlite3://#{dev_prefix}database.sqlite3"
DataMapper.setup(:default, ENV['DATABASE_URL'])

class Snippet
  include DataMapper::Resource

  property :id,         Serial
  property :body,       Text, :required => true, :length => 1..1000
  property :user_agent, String, :length => 0..512
  property :ip_address, String, :length => 1..24 # really only 16
  property :referer,    String, :length => 0..1024
  property :created_at, DateTime
  property :updated_at, DateTime

  def formatted_body
    @@coder ||= HTMLEntities.new
    encoded = @@coder.encode(body, :named) # ecscape all special chars
    newline = "\r\n" # inconsistent between systems :(
    encoded.gsub!(/(#{newline}#{newline})+/, newline) # replace >2 newlines in a row with just 1 (allow paragraphs)
    encoded.gsub!(newline, "<br />") # then turn newlines into HTML
    return encoded
  end
end

DataMapper.auto_upgrade!

# new
get '/' do
  @posts = Snippet.all(:order => [:created_at.desc], :limit => 3)
  erb :new
end

# index
get '/posts' do
  @posts = Snippet.all(:order => [:created_at.desc], :limit => 100)
  erb :index
end

# create
post '/' do
  @post = Snippet.new(:body => params[:snippet_body], :created_at => DateTime.now,
                  :ip_address => request.ip, :user_agent => request.user_agent, :referer => request.referer)
  if @post.save
    redirect "/"
  else
    erb :error, :status => 400
  end
end

# show
get '/:id' do
  @post = Snippet.get(params[:id])
  if @post
    erb :show
  else
    redirect '/'
  end
end
