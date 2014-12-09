class AlterMovesFieldTypeFromGame < ActiveRecord::Migration
  def change
    change_column :games, :moves, :text
  end
end
