class TodoItem < ActiveRecord::Base

	def self.number_of_completed_tasks
		TodoItem.all.where(completed: true).count
	end

end
