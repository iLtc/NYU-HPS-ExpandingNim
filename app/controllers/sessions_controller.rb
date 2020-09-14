require 'securerandom'

class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    @sessions = Session.order(id: :desc)
  end
    
  def new
  end
  
  def create
    session = Session.new
    session.status = "wait_for_b_join"
    session.initial_stones = params[:stones]
    session.left_stones = params[:stones]
    session.current_max = 0
    session.reset = false
    session.accept_max_stones = [3, session.initial_stones].min
    
    player_a = User.new
    player_a.name = params[:name]
    player_a.token = SecureRandom.hex(16)
    player_a.left_resets = 4
    player_a.left_time = 120
    player_a.player_a_session = session
    
    if !player_a.save
      respond_to do |format|
        format.html do
          flash[:alert] = "Please fix errors below."
          @errors = player_a.errors.messages
          render :new
        end

        format.json do
          render json: {
            status: "failed",
            reason: "Please fix errors below.",
            errors: player_a.errors.messages
          }.to_json
        end
      end
      
      return
    end
    
    if !session.save
      respond_to do |format|
        format.html do
          flash[:alert] = "Please fix errors below."
          @errors = session.errors.messages
          render :new
        end

        format.json do
          render json: {
            status: "failed",
            reason: "Please fix errors below.",
            errors: session.errors.messages
          }.to_json
        end
      end
      
      return
    end
    
    respond_to do |format|
      format.html do
        redirect_to session_status_path(session, token: player_a.token), notice: "A new session has been created."
      end
      
      format.json do
        render json: {
          status: "success",
          game_status: session.status,
          session_id: session.id,
          token: player_a.token
        }.to_json
      end
    end
  end
  
  def join
    @id = params[:session_id]
  end
  
  def join_post
    begin
      session = Session.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      respond_to do |format|
        format.html do
          redirect_to sessions_path, alert: "Couldn't find Session with the given id."
        end

        format.json do
          render json: {
            status: "failed",
            reason: "Couldn't find Session with the given id."
          }.to_json
        end
      end
      
      return
    end
    
    unless session.player_b.nil?
      respond_to do |format|
        format.html do
          redirect_to sessions_path, alert: "Player B already exists."
        end

        format.json do
          render json: {
            status: "failed",
            reason: "Player B already exists."
          }.to_json
        end
      end
      
      return
    end
    
    player_b = User.new
    player_b.name = params[:name]
    player_b.token = SecureRandom.hex(16)
    player_b.left_resets = 4
    player_b.left_time = 120
    player_b.player_b_session = session
    
    if !player_b.save
      respond_to do |format|
        format.html do
          flash[:alert] = "Please fix errors below."
          @errors = player_b.errors.messages
          render :join
        end

        format.json do
          render json: {
            status: "failed",
            reason: "Please fix errors below.",
            errors: player_b.errors.messages
          }.to_json
        end
      end
      
      return
    end
    
    session.status = "wait_for_a_move"
    
    session.save
    
    respond_to do |format|
      format.html do
        redirect_to session_status_path(session, token: player_b.token), notice: "You have joined this session."
      end
      
      format.json do
        render json: {
          status: "success",
          game_status: session.status,
          session_id: session.id,
          token: player_b.token
        }.to_json
      end
    end
  end
  
  def show
    begin
      @session = Session.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      respond_to do |format|
        format.html do
          redirect_to sessions_path, alert: "Couldn't find Session with the given id."
        end

        format.json do
          render json: {
            status: "failed",
            reason: "Couldn't find Session with the given id."
          }.to_json
        end
      end
      
      return
    end
  end
  
  def status
    valid, @session, @current_player, @your_turn = verify_session_and_player
    
    unless valid
      return
    end
    
    @message = @session.status_message
    
    if @your_turn and @current_player.start_time.nil?
      @current_player.start_time = DateTime.now
      @current_player.save
    end
    
  end
  
  def move
    valid, session, current_player, your_turn = verify_session_and_player
    
    unless valid
      return
    end
    
    unless your_turn
      respond_to do |format|
        format.html do
          redirect_to session_status_path(session, token: current_player.token), notice: "It is not your turn yet."
        end

        format.json do
          render json: {
            status: "failed",
            reason: "It is not your turn yet."
          }.to_json
        end
      end
      
      return
    end
    
    if current_player.start_time.nil?
      respond_to do |format|
        format.html do
          redirect_to session_status_path(session, token: current_player.token), alert: "Please request status before making move."
        end

        format.json do
          render json: {
            status: "failed",
            reason: "Please request status before making move."
          }.to_json
        end
      end
      
      return
    end
    
    if params[:stones].to_i < 1 || params[:stones].to_i > session.accept_max_stones
      respond_to do |format|
        format.html do
          redirect_to session_status_path(session, token: current_player.token), alert: "# of Stones to Remove has to be brtween 1 and #{session.accept_max_stones}."
        end

        format.json do
          render json: {
            status: "failed",
            reason: "# of Stones to Remove has to be brtween 1 and #{session.accept_max_stones}."
          }.to_json
        end
      end
      
      return
    end
    
    if params[:reset] == 'yes' and current_player.left_resets == 0
      respond_to do |format|
        format.html do
          redirect_to session_status_path(session, token: current_player.token), alert: "You have used all your resets."
        end

        format.json do
          render json: {
            status: "failed",
            reason: "You have used all your resets."
          }.to_json
        end
      end
      
      return
    end
    
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
    session.current_max = [move.stones_removed, session.current_max].max
    session.reset = move.reset
    session.accept_max_stones = [move.reset ? 3 : [3, session.current_max + 1].max, session.left_stones].min
    session.moves << move
    
    if session.left_stones <= 0
      session.status = "end"
      session.winner = (current_player == session.player_a) ? 1 : 2
    else
      session.status = (current_player == session.player_a) ? "wait_for_b_move" : "wait_for_a_move"
    end
      
    session.save
    current_player.save
    move.save
    
    respond_to do |format|
      format.html do
        redirect_to session_status_path(session, token: current_player.token)
      end
      
      format.json do
        render json: {
          status: "success"
        }.to_json
      end
    end
  end
  
  def verify_session_and_player
    begin
      session = Session.find(params[:session_id])
    rescue ActiveRecord::RecordNotFound => e
      respond_to do |format|
        format.html do
          redirect_to sessions_path, alert: "Couldn't find Session with the given id."
        end

        format.json do
          render json: {
            status: "failed",
            reason: "Couldn't find Session with the given id."
          }.to_json
        end
      end
      
      return false, nil, nil, nil
    end
    
    token = params[:token]
    
    if session.player_a.token == token
      current_player = session.player_a
    
    elsif !session.player_b.nil? and session.player_b.token == token
      current_player = session.player_b
      
    else
      respond_to do |format|
        format.html do
          redirect_to sessions_path, alert: "Your token does not match any of the players."
        end

        format.json do
          render json: {
            status: "failed",
            reason: "Your token does not match any of the players."
          }.to_json
        end
      end
      
      return false, nil, nil, nil
    end
    
    your_turn = false
    
    case session.status
      when "wait_for_b_join", "end"
        your_turn = false
      when "wait_for_a_move"
        if current_player == session.player_a
          your_turn = true
        end
      when "wait_for_b_move"
        if current_player == session.player_b
          your_turn = true
        end
      else
        your_turn = false
    end
    
    return true, session, current_player, your_turn
  end
end
