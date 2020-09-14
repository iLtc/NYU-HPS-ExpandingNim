require 'securerandom'

class SessionsController < ApplicationController
  def index
    @sessions = Session.all
  end
    
  def new
  end
  
  def create
    # TODO: Valid name and stones
    session = Session.new
    session.status = "wait_for_b_join"
    session.initial_stones = params[:stones]
    session.left_stones = params[:stones]
    session.current_max = 0
    session.reset = false
    session.accept_max_stones = 3
    
    player_a = User.new
    player_a.name = params[:name]
    player_a.token = SecureRandom.hex(16)
    player_a.left_resets = 4
    player_a.left_time = 120
    player_a.player_a_session = session
    
    player_a.save
    session.save
    
    redirect_to session_status_path(session, token: player_a.token)
  end
  
  def join
    @id = params[:session_id]
  end
  
  def join_post
    # TODO: Valid name and id
    session = Session.find(params[:id])
    
    player_b = User.new
    player_b.name = params[:name]
    player_b.token = SecureRandom.hex(16)
    player_b.left_resets = 4
    player_b.left_time = 120
    player_b.player_b_session = session
    
    player_b.save
    
    session.status = "wait_for_a_move"
    
    session.save
    
    redirect_to session_status_path(session, token: player_b.token)
  end
  
  def show
    @session = Session.find(params[:id])
  end
  
  def status
    # TODO: Valid token and id
    @session = Session.find(params[:session_id])
    token = params[:token]
    
    if @session.player_a.token == token
      @current_player = @session.player_a
    
    elsif !@session.player_b.nil? and @session.player_b.token == token
      @current_player = @session.player_b
      
    else
      # TODO: error
      
    end
    
    @you_turn = false
    @message = @session.status_message
    
    case @session.status
      when "wait_for_b_join", "end"
        @you_turn = false
      when "wait_for_a_move"
        if @current_player == @session.player_a
          @you_turn = true
        end
      when "wait_for_b_move"
        if @current_player == @session.player_b
          @you_turn = true
        end
      else
        @you_turn = false
    end
    
    if @current_player.start_time.nil?
      @current_player.start_time = DateTime.now
      @current_player.save
      puts @current_player.start_time
    end
    
  end
  
  def move
    # TODO: Valid token and id, and value range
    
    # TODO: Valid token and id
    session = Session.find(params[:session_id])
    token = params[:token]
    
    if session.player_a.token == token
      current_player = session.player_a
    
    elsif !session.player_b.nil? and session.player_b.token == token
      current_player = session.player_b
      
    else
      # TODO: error
      
    end
    
    you_turn = false
    message = session.status_message
    
    case session.status
      when "wait_for_b_join", "end"
        you_turn = false
      when "wait_for_a_move"
        if current_player == session.player_a
          you_turn = true
        end
      when "wait_for_b_move"
        if current_player == session.player_b
          you_turn = true
        end
      else
        you_turn = false
    end
    
    if !you_turn
      # TODO: Error
    end
    
    # TODO: if current_player.start_time is nil
    
    move = Move.new
    move.start_time = current_player.start_time
    move.end_time = DateTime.now
    move.stones_before = session.left_stones
    move.stones_removed = params[:stones]
    move.stones_after = move.stones_before - move.stones_removed
    move.reset_before = current_player.left_resets
    move.reset = (params[:reset] == 'yes') ? true : false
    move.reset_after = move.reset_before - (move.reset ? 1 : 0)
    
    current_player.left_resets = move.reset_after
    current_player.left_time -= move.end_time.to_i - move.start_time.to_i
    current_player.start_time = nil
    current_player.moves << move
    
    session.left_stones = move.stones_after
    session.current_max = move.stones_removed + 1
    session.reset = move.reset
    session.accept_max_stones = move.reset ? 3 : [3, session.current_max].max
    session.moves << move
    
    if session.left_stones <= 0
      session.status = "end"
      session.winner = (current_player == session.player_a) ? "1" : "2"
    else
      session.status = (current_player == session.player_a) ? "wait_for_b_move" : "wait_for_a_move"
    end
      
    session.save
    current_player.save
    move.save
    
    redirect_to session_status_path(session, token: current_player.token)
  end
  
  def verify_session_and_player
    
  end
end
