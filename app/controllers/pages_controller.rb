class PagesController < ApplicationController
    
  def front_page
    @albums= Album.order("RAND()").includes(:primary_images, :collections).first(6).shuffle
    
    @albumtotal = Album.count
    @artisttotal = Artist.count
    @sourcetotal = Source.count
    @orgtotal = Organization.count
    @songtotal = Song.count
    @imagetotal = Image.count
    @relationships = Imagelist.count +
      AlbumOrganization.count +
      AlbumEvent.count +
      ArtistAlbum.count +
      AlbumSource.count +
      ArtistOrganization.count +
      ArtistSong.count +
      SongSource.count +
      SourceOrganization.count + 
      RelatedArtists.count +
      RelatedSources.count +
      RelatedOrganizations.count +
      RelatedAlbums.count +
      Song.count
  end
  
  def search
    authorize! :read, Album
    @query = params[:search]
    
    if params[:model].nil? == false
      @model = params[:model]
    end
    
    if params[:model].nil? or params[:model] == "Album"
      albumresults = Album.search(:include => [:primary_images])  do
        fulltext params[:search]
        order_by(:releasedate)
        paginate :page => params[:albumpage]
      end
      @albums = albumresults.results
    end
    
    if params[:model].nil? or params[:model] == "Artist"
      artistresults = Artist.search(:include => [albums: :primary_images])  do
        fulltext params[:search]
        paginate :page => params[:artistpage]
      end
      @artists = artistresults.results
    end
    
    if params[:model].nil? or params[:model] == "Source"
      sourceresults = Source.search(:include => [albums: :primary_images])   do
        fulltext params[:search]
        paginate :page => params[:sourcepage]
      end
      @sources = sourceresults.results
    end
          
    if params[:model].nil? or params[:model] == "Organization"
      orgresults = Organization.search(:include => [albums: :primary_images])  do
        fulltext params[:search]
        paginate :page => params[:orgpage]
      end
      @organizations = orgresults.results
    end
      
    if params[:model].nil? or params[:model] == "Song"
      songresults = Song.search(:include => [album: :primary_images])  do
        fulltext params[:search]
        paginate :page => params[:songpage]
      end
      @songs = songresults.results
    end
     
  end
  
  def calendar
    authorize! :read, Album
    
    date = params[:date]
    if date.nil? == false
      date = Date.parse(date)
    else
      date ||= Date.today
    end
    enddate = date + 30
    @albums = Album.where(:releasedate => date..enddate).includes(:primary_images)
  end
  
  def calendar_update
    authorize! :read, Album
    
    date = params[:datepicker][:date]
    if date.nil?
      date = Date.today
    else
      date = Date.strptime(date, '%m/%d/%Y')
    end
    enddate = date + 30
    
    @albums = Album.where(:releasedate => date..enddate).includes(:primary_images)
  end
  
  def randomalbums #Just a fun side-project to display   
    authorize! :read, Album
    
    @numberofalbums = 100
    @slice = (@numberofalbums / 6.0).ceil
    @albums= Album.order("RAND()").includes(:primary_images).first(@numberofalbums).shuffle
    # @albums= Album.includes(:covers).last(@numberofalbums)
  end  

end
