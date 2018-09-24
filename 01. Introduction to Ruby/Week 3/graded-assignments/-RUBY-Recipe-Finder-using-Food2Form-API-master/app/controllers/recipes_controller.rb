class RecipesController < ApplicationController
  def index
		@search_value = params[:search] || 'chocolate'
		@api_return_value = Recipe.for(@search_value)	
  end
end
