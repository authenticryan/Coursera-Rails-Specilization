class ChageTodoItemDescriptionFromStringToText < ActiveRecord::Migration
  def up
		change_column :todo_items, :description, :text
	end

	def down 
		change_column :todo_items, :description, :string
	end
end
