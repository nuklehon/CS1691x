class MoviesController < ApplicationController

  attr_reader :sorting

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    if session.has_key?(:cookie) and !(params.has_key?(:sorting) or params.has_key?(:commit))
      logger.debug 'use cookie'

      #apply this cookie
      redirect_to movies_path(session[:cookie])
    end
    
    session.delete(:cookie) 

    #Initialize checked ratings in the form
    @all_ratings = Hash.new
    #All to true (default)
    Movie.load_ratings.each { |r| @all_ratings[r] = true }

    #Retrieve sorting
    @sorting = params[:sorting]

    # Retrieve ratings in a Hash
    checked_ratings = Hash.new
    #for each element, set value to "true" (unless not nil to avoid error)
    checked_ratings = params[:ratings].select{|k, v| v == "true"} unless params[:ratings] == nil

    if(params.has_key?(:commit) or params.has_key?(:sorting)) 

      # bind the static variable for the form construction (next display)
      Movie.load_ratings.each { |r| @all_ratings[r] = checked_ratings.has_key?(r) }

      if checked_ratings.empty?
        @movies = []
      else  
        # return @movies after filtering by ratings that have been checked
        @movies = Movie.find(:all, :conditions => [ "rating IN (?)", checked_ratings.keys], :order => @sorting)
      end

      # add cookie for the next request (if needed)
      session[:cookie] = params

    else

      # Display all movies
      @movies = Movie.find(:all)

    end

  end 

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
