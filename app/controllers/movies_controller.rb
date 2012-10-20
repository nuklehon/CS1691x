class MoviesController < ApplicationController

  attr_reader :sorting

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index

    # Load all ratings from model
    # Initialize checked to true for each rate
    @all_ratings = Hash.new
    Movie.load_ratings.each { |r| @all_ratings[r] = true }
    #logger.debug @all_ratings


    if !params['ratings'].nil?
      #logger.debug 'params not null'
      #check only ratings which are in the Parameters
      Movie.load_ratings.each do |r|
        has_key = params['ratings'].has_key?(r)
        if has_key
          value = params['ratings'][r]
          #logger.debug 'value'
          #logger.debug value
          if value == "true"
            #logger.debug 'in'
            @all_ratings[r] = true
          else
            #logger.debug 'out'
            @all_ratings[r] = false
          end
        else
          #logger.debug 'out'
          @all_ratings[r] = false
        end
      end  
    else
      #logger.debug 'empty'
      #No ratings are selectd -> all true
      Movie.load_ratings.each { |r| @all_ratings[r] = true }
    end

    #logger.debug 'filter'
    #logger.debug @all_ratings


    # Sorting
    if !params[:sorting].nil?
      #logger.debug 'sorting is not null'
      @sorting = params[:sorting]
    end
      

    if !params['ratings'].nil?
      #logger.debug params['ratings'].keys
      @movies = Movie.find(:all, :conditions => [ "rating IN (?)", params['ratings'].keys], :order => sorting)
    else
      @movies = Movie.find(:all, :order => sorting)
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
