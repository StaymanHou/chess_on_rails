class GamesController < ApplicationController
  before_action :set_game, only: [:show, :edit, :update, :destroy, :move]
  before_action :set_move, only: [:move]

  # GET /games
  # GET /games.json
  def index
    @games = Game.all
  end

  # GET /games/1
  # GET /games/1.json
  def show
    chess_game = PGN::Game.new(@game.moves)
    @error = nil
    begin
      @fen = chess_game.positions.last.to_fen
      @fen = PGN::FEN.start if @game.moves.empty?
    rescue
      @fen = ''
      flash[:alert] = 'Invalid moves.'
      @error = 'Invalid moves.'
    end
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /games/1/move/e4.json
  def move
    @game.moves << @move
    chess_game = PGN::Game.new(@game.moves)
    @error = nil
    begin
      @fen = chess_game.positions.last.to_fen
    rescue
      @fen = ''
      flash[:alert] = 'Invalid move.'
      @error = 'Invalid move.'
    else
      @game.save
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game
      @game = Game.find(params[:id])
    end

    def set_move
      @move = params[:move]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_params
      permitted_params = params.require(:game).permit(:moves)
      permitted_params[:moves] = JSON.parse(permitted_params[:moves])
      permitted_params
    end
end
