class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(NR G PG PG-13 NC-17 R)
  end
  
class Movie::InvalidKeyError < StandardError ; end
  
def self.find_in_tmdb(string)
  begin
    tmdbMovies = Tmdb::Movie.find(string)
  rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
  end
  movies = [];
  if tmdbMovies != nil
    tmdbMovies.each do |tmdbMovie|
      movie = {};
      movie[:title] = tmdbMovie.title;
      movie[:tmdb_id] = tmdbMovie.id;
      countries = Tmdb::Movie.releases(tmdbMovie.id)["countries"];
      puts countries
      puts "\n"
      us_releases = countries && countries.find_all{|country| country["iso_3166_1"] == "US"};
      rated = us_releases && us_releases.find{|release| release["certification"] != nil && !(release["certification"].empty?)};
      movie[:rating] = rated && rated["certification"];
      movie[:release_date] = tmdbMovie.release_date;
      if movie[:rating] != nil && !(movie[:rating].empty?)
        movies.push(movie);
      end
    end
  end
  return movies;
end

def self.create_from_tmdb(tmdb_id)
  movie = Tmdb::Movie.detail(tmdb_id);
  puts movie
  movie_params = {};
  movie_params[:title] = movie["title"];
  countries = Tmdb::Movie.releases(tmdb_id)["countries"];
  us_release = countries && countries.find{|country| country["iso_3166_1"] == "US"};
  movie_params[:rating] = us_release && us_release["certification"];
  movie_params[:release_date] = movie["release_date"];
  movie_params[:description] = movie["overview"];
  Movie.create!(movie_params);
end

end
