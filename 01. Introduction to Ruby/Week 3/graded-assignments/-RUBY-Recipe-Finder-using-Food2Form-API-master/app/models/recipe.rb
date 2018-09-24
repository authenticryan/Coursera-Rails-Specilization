require 'httparty'

# food2fork_key is 77ae1fc668c176486dc47d6cbd58cf08

class Recipe
	include HTTParty

	hostport = ENV["FOOD2FORK_SERVER_AND_PORT"] || 'www.food2fork.com'
	base_uri "http://#{hostport}/api"
	default_params key: ENV['FOOD2FORK_KEY']
	format :json

	def self.for(search_keyword)
		get("/search", query: {q: search_keyword})
	end
end

