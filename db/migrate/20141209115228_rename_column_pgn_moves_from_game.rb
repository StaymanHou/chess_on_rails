class RenameColumnPgnMovesFromGame < ActiveRecord::Migration
  def change
    Game.destroy_all
    rename_column :games, :pgn, :moves
  end
end
