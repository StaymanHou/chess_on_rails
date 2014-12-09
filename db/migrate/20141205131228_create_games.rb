class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :pgn

      t.timestamps
    end
  end
end
