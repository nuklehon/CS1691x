class Movie < ActiveRecord::Base

	def self.load_ratings
		return ['G','PG','PG-13','R']
	end

end
