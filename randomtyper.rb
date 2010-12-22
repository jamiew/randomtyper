#!/usr/bin/env ruby -rubygems

require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'
require 'htmlentities'
require 'newrelic_rpm'

dev_prefix = ENV['RACK_ENV'] == 'development' ? File.expand_path(File.dirname(__FILE__))+'/' : ''
ENV['DATABASE_URL'] ||= "sqlite3://#{dev_prefix}randomtyper.sqlite3"
DataMapper.setup(:default, ENV['DATABASE_URL'])

class Snippet
  include DataMapper::Resource

  property :id,         Serial
  property :body,       Text, :required => true, :length => 1..255
  property :created_at, DateTime
  property :updated_at, DateTime

  def formatted_body
    @@coder ||= HTMLEntities.new
    return @@coder.encode(body, :named)
  end
end

DataMapper.auto_upgrade!

# new
get '/' do
  @snippets = Snippet.all(:order => [:created_at.desc], :limit => 50)
  erb :new
end

# create
post '/' do
  @snippet = Snippet.new(:body => params[:snippet_body], :created_at => DateTime.now)
  if @snippet.save
    redirect "/"
  else
    erb :error, :status => 400
  end
end

# show
get '/:id' do
  @snippet = Snippet.get(params[:id])
  if @snippet
    erb :show
  else
    redirect '/'
  end
end
