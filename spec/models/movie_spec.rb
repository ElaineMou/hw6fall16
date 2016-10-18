
describe Movie do
  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        expect( Tmdb::Movie).to receive(:find).with('Inception')
        Movie.find_in_tmdb('Inception')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
    context 'with no movie found' do
      it 'should return array with length 0' do
        allow(Tmdb::Movie).to receive(:find).with('blahblahblah').and_return(nil)
        expect(Movie.find_in_tmdb('blahblahblah')).to eq([])
      end
    end
    context 'with valid search terms' do
      it 'should find multiple movies if search terms are valid' do
      fake_results = [double('movie1'),double('movie2'),double('movie3')]
        
      releases1 = {"countries" => [{"iso_3166_1" =>"US", "certification"=>""}, {"iso_3166_1" =>"US", "certification"=>"PG"}]};
      releases2 = {"countries" => [{"iso_3166_1" =>"DE", "certification"=>""}, {"iso_3166_1" =>"US", "certification"=>"R"}]};
      releases3 = {"countries" => [{"iso_3166_1" =>"DE", "certification"=>""}, {"iso_3166_1" =>"US", "certification"=>""}]};
      movie1 = fake_results[0];
      movie2 = fake_results[1];
      movie3 = fake_results[2];
      allow(movie1).to receive(:id).and_return("100");
      allow(movie1).to receive(:title).and_return("Inception 1");
      allow(movie1).to receive(:release_date).and_return("2010-07-14");
      allow(movie2).to receive(:id).and_return("200");
      allow(movie2).to receive(:title).and_return("Inception 2");
      allow(movie2).to receive(:release_date).and_return("2010-12-07");
      allow(movie3).to receive(:id).and_return("300");
      allow(movie3).to receive(:title).and_return("Inception 3");
      allow(movie3).to receive(:release_date).and_return("2011-06-09");
      allow(Tmdb::Movie).to receive(:releases).with("100").and_return(releases1);
      allow(Tmdb::Movie).to receive(:releases).with("200").and_return(releases2);
      allow(Tmdb::Movie).to receive(:releases).with("300").and_return(releases3);
      allow(Tmdb::Movie).to receive(:find).with('Inception').and_return(fake_results)
      

      movies = Movie.find_in_tmdb('Inception');
      expect(movies.length).to eq(2)
      expect(movies[0][:tmdb_id]).to eq("100");
      expect(movies[0][:title]).to eq("Inception 1");
      expect(movies[0][:rating]).to eq("PG");
      expect(movies[1][:tmdb_id]).to eq("200");
      expect(movies[1][:title]).to eq("Inception 2");
      expect(movies[1][:rating]).to eq("R");
      end
    end
    
  end
end
