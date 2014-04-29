require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

get '/' do
  erb :boots
end

post '/myaction' do
  puts params[:username]
end

