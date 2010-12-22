#!/usr/local/bin/ruby -rubygems

require 'sinatra'
require 'dm-core'
require 'dm-validations'
require 'dm-timestamps'
require 'dm-migrations'

# ENV['DATABASE_URL'] ||= "sqlite3://#{File.dirname(__FILE__)}/randomtyper.db"
ENV['DATABASE_URL'] ||= "sqlite3://randomtyper.db"
puts "Database: #{ENV['DATABASE_URL']}"
DataMapper.setup(:default, ENV['DATABASE_URL'])

class Snippet
  include DataMapper::Resource

  property :id,         Serial # primary key
  property :body,       Text,   :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :body
  validates_length_of :body, :minimum => 1

  def formatted_body
    # TODO parse out bad shit
    return body
  end
end

DataMapper.auto_upgrade!

# new
get '/' do
  @snippets = Snippet.all(:order => [:created_at.desc], :limit => 5)
  erb :new
end

# create
post '/' do
  @snippet = Snippet.new(:body => params[:snippet_body], :created_at => DateTime.now)
  if @snippet.save!
    # redirect "/#{@snippet.id}"
    redirect "/"
  else
    [400, 'Error: feels bad man :(']
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
