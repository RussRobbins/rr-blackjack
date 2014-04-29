require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

get '/' do
  erb :get_name
end

post '/get_name' do
  puts params[:username]
end

