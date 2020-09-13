require 'securerandom'

class SessionsController < ApplicationController
  def index
    @sessions = Session.all
  end
    
  def new
  end
  
  def create
    session = Session.new
    
    player_a = User.new
    player_a.name = params[:name]
    player_a.token = SecureRandom.hex(16)
    player_a.player_a_session = session
    
    player_a.save
    session.save
    
    redirect_to controller: 'sessions', action: 'show', id: session.id, token: player_a.token
  end
  
  def join
    @id = request.query_parameters["id"]
  end
  
  def join_post
    session = Session.find(params[:id])
    
    player_b = User.new
    player_b.name = params[:name]
    player_b.token = SecureRandom.hex(16)
    player_b.player_b_session = session
    
    player_b.save
    session.save
    
    redirect_to controller: 'sessions', action: 'show', id: session.id, token: player_b.token
  end
  
  def show
    
  end
end
