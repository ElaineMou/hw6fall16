class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title_header = {:title => :asc}, 'hilite'
    when 'release_date'
      ordering,@date_header = {:release_date => :asc}, 'hilite'
    end
    @all_ratings = Movie.all_ratings
    @selected_ratings = params[:ratings] || session[:ratings] || {}
    
    if @selected_ratings == {}
      @selected_ratings = Hash[@all_ratings.map {|rating| [rating, rating]}]
    end
    
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(ordering)
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  def search_tmdb
    search_terms = params[:search_terms];
    if search_terms == nil || search_terms.blank?
      flash[:warning] = "Invalid search term"
      puts "Invalid search term: " + search_terms
      redirect_to movies_path
    else
      @search_terms = search_terms
      @movies=Movie.find_in_tmdb(search_terms)
      if @movies == nil || @movies.length == 0 
        flash[:notice] = "No matching movies were found on TMDb"
        puts "No matching movies: " + search_terms
        redirect_to movies_path
      end
    end
  end
  
  def add_tmdb
    hash = params[:tmdb_movies]
    puts params
    if hash == nil || hash.empty?
      flash[:notice] = "No movies selected"
    else
      tmdb_ids = hash.keys;
      tmdb_ids.each do |tmdb_id|
        Movie::create_from_tmdb(tmdb_id);
      end
      flash[:notice] = "Movies successfully added to Rotten Potatoes"
    end
    redirect_to movies_path
  end

end
