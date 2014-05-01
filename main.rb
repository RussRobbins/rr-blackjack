require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'

set :sessions, true

get '/restart' do
  session[:username] = nil
  redirect '/'
end

get '/' do
  if session[:username]
    redirect '/game'
  else
    redirect '/get_name'
  end
end

get '/get_name' do
  session[:cash] = 500
  erb :get_name
end

post '/get_name' do
  session[:username] = params[:username]
  redirect '/game'
end

get '/game' do
  erb :game
end