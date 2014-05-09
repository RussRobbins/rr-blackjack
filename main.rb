require 'rubygems'
#require 'sinatra'
#require 'sinatra/reloader'

set :sessions, true

# Constants for blackjack
BLACKJACK = 21
DEALER_HIT_BELOW = 17


before do
  @show_dealer_hole_card = false
  @show_player_controls = true
  @show_dealer_controls = false
  @play_again = false
end

# Helper methods

helpers do

  def init_deck
    suits = ['Spades', 'Clubs', 'Diamonds', 'Hearts']
    ranks = ['Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King']
    new_deck = suits.product(ranks)
    new_deck.shuffle!
  end

  def initial_deal(player_cards, dealer_cards, deck)
    2.times do
      player_cards << deck.pop
      dealer_cards << deck.pop 
    end
  end

  def draw_card(card)
    "<img class='card img-rounded' src='/images/cards/#{card[0].downcase}_#{card[1].downcase}.jpg' />"
  end

  def draw_cover()
    "<img class='card img-rounded' src='/images/cards/cover.jpg' />"
  end

  def count(hand)
    ranks = hand.map do |card|
      card[1]
    end
    total = 0
    ranks.each do |x|
      if x == "Ace"
        total += 11
      else
        total += (x.to_i == 0) ? 10 : x.to_i
      end
    end
    ranks.select{|x| x == "Ace"}.count.times do
      break if total <= BLACKJACK
      total -= 10
    end
    total
  end

  def setup_endgame
    @show_dealer_hole_card = true
    @show_player_controls = false
    @show_dealer_controls = false
    @play_again = true
  end

  def win!(text)
    setup_endgame
    session[:cash] += session[:bet]
    @win = "#{text}"
  end

  def lose!(text)
    setup_endgame
    session[:cash] -= session[:bet]
    @lose = "#{text}"
  end

  def draw!(text)
    setup_endgame
    @draw = "#{text}"
  end

  # This is only called if both player and dealer have both stayed and not busted or hit 21
  def endgame()
    pval = count(session[:player_cards])
    dval = count(session[:dealer_cards])
    if pval > dval
      win!("<h3>#{session[:username]}'s #{pval} beats the dealer's #{dval}! #{session[:username]} won $#{session[:bet]} and now has $#{session[:cash]+session[:bet]}.</h3>")
    elsif dval > pval
      lose!("<h3>The dealer's #{dval} beats #{session[:username]}'s #{pval}! #{session[:username]} lost $#{session[:bet]} and now has $#{session[:cash]-session[:bet]}.</h3>")
    else
      draw!("<h3>It's a DRAW! Both #{session[:username]} and the dealer have #{pval}.</h3>")
    end
  end

end

# Routing code

get '/restart' do
  session[:username] = nil
  redirect '/'
end

get '/' do
  if session[:username]
    redirect '/bet'
  else
    redirect '/get_name'
  end
end

get '/get_name' do
  session[:cash] = 500
  erb :get_name
end

post '/get_name' do
  if  params[:username] == nil || params[:username] == ""
    @error = "<h3>You must enter a name. Try again.</h3>"
    erb :get_name
  else
    session[:username] = params[:username]
    redirect '/bet'
  end
end

get '/bet' do
  erb :bet
end

post '/bet' do
  bet = params[:bet_amt].to_i
  if  bet > session[:cash]
    @error = "<h3>You don't have that much!  Try again.</h3>"
    erb :bet
  elsif bet <= 0
    @error = "<h3>You have to bet <i>something</i>!  Try again.</h3>"
    erb :bet
  else
    session[:bet] = bet
    redirect '/game'
  end
end

get '/game' do
  session[:deck] = init_deck
  session[:player_cards] = []
  session[:dealer_cards] = []
  initial_deal(session[:player_cards], session[:dealer_cards], session[:deck])
  if count(session[:player_cards]) == 21
    win!("<h3>#{session[:username]} GOT BLACKJACK! #{session[:username]} won $#{session[:bet]} and now has $#{session[:cash]+session[:bet]}.</h3>")
  elsif count(session[:dealer_cards]) == 21
    lose!("<h3>THE DEALER GOT BLACKJACK! #{session[:username]} lost $#{session[:bet]} and now has $#{session[:cash]-session[:bet]}.</h3>")

    
  end
  erb :game
end

post '/hit' do
  session[:player_cards] << session[:deck].pop
  total = count(session[:player_cards])
  if total == BLACKJACK
    win!("<h3>#{session[:username]} GOT 21! #{session[:username]} won $#{session[:bet]} and now has $#{session[:cash]+session[:bet]}.</h3>")
  elsif total > BLACKJACK
    lose!("<h3>#{session[:username]} HAS BUSTED AT #{total}! #{session[:username]} lost $#{session[:bet]} and now has $#{session[:cash]-session[:bet]}.</h3>")
  end
  erb :game
end

post '/stay' do
  total = count(session[:dealer_cards])
  if total >= DEALER_HIT_BELOW
    endgame
  end
  @show_dealer_hole_card = true
  @show_player_controls = false
  @show_dealer_controls = true
  erb :game
end

post '/dealer_hit' do
  session[:dealer_cards] << session[:deck].pop
  total = count(session[:dealer_cards])
  if total == BLACKJACK
    lose!("<h3>The dealer GOT 21! #{session[:username]} lost $#{session[:bet]} and now has $#{session[:cash]-session[:bet]}.</h3>")
  elsif total > BLACKJACK
    win!("<h3>THE DEALER HAS BUSTED AT #{total}! #{session[:username]} won $#{session[:bet]} and now has $#{session[:cash]+session[:bet]}.</h3>")
  elsif total >= DEALER_HIT_BELOW
    endgame
  end
  @show_dealer_controls = true
  @show_dealer_hole_card = true
  @show_player_controls = false
  erb :game
end
