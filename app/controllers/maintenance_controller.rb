class MaintenanceController < ApplicationController
  
  def index
    authorize! :edit, Album
  end
  
  #Scrapes
    def scrapeanalbum
      authorize! :scrapepage, Album
    end
  
    def scrape
      authorize! :scrape, Album
      scrapehash = {}
      scrapehash[:vgmdb_artists] = params[:vgmdb_artists].reject(&:empty?)
      scrapehash[:vgmdb_organizations] = params[:vgmdb_orgs].reject(&:empty?)
      scrapehash[:vgmdb_albumlist] = params[:vgmdb_albumlist][:text]
      scrapehash[:cdjapan_albums] = params[:cdjapan_albums].reject(&:empty?)
      scrapehash[:manifo_albums] = params[:manifo_albums].reject(&:empty?)
      
      if scrapehash[:vgmdb_artists].empty? == false || scrapehash[:vgmdb_organizations].empty? == false || scrapehash[:cdjapan_albums].empty? == false || scrapehash[:vgmdb_albumlist].empty? == false || scrapehash[:manifo_albums].empty? == false
        postmessage = "Scrape started at " + Time.now.to_s + " with inputs: "
        postmessage << "\n\nvgmdb albums: "
        scrapehash[:vgmdb_albumlist].split("\n").reject { |a| a.empty?}.select { |a| a.starts_with?("http://") }.each do |each|
          (scrapehash[:vgmdb_albums] ||= []) << each.chomp("\r")
        end
        scrapehash[:vgmdb_albums].each {|each| postmessage << "\n"  + each }
        postmessage << "\n\nvgmdb artists/sources: "
        scrapehash[:vgmdb_artists].each {|each| postmessage << "\n" + each }
        postmessage << "\n\nvgmdb orgs/search results: "
        scrapehash[:vgmdb_organizations].each {|each| postmessage << "\n" + each }
        postmessage << "\n\ncdjapan albums: "
        scrapehash[:cdjapan_albums].each {|each| postmessage << "\n" + each } 
        postmessage << "\n\nmanifo albums: "
        scrapehash[:manifo_albums].each {|each| postmessage << "\n" + each } 
        postmessage << "\n\n Scrape Log: "
  
        @post = Post.create(category: "Scrape Result", status: "Released", visibility: "Scraper", content: postmessage)
        ScrapeWorker.perform_async(scrapehash,@post.id)      
      end
          
      respond_to do |format|
        if @post.nil? == false
          format.html { redirect_to(maintenance_scraperesults_path(:post_id => @post.id)) }
          format.json { head :no_content }
        else
          format.html { redirect_to maintenance_scrapeanalbum_path, notice: 'No links were specified!' }
          format.json { head :no_content }
        end
      end 
    end 
  
    def scraperesults
      authorize! :scrape, Album
      if params[:post_id].nil? == false
        @post = Post.find(params[:post_id])
      else
        @post = Post.where(:category => "Scrape Result").last
      end
      albumids = []
      @failedurls = []
      @post.content.force_encoding("UTF-8")
      @post.content.scan(/\[FAILED\]\[[a-z0-9\.:\/]+\]\[\d{1,5}\]/).each do |each|
        @album = Album.find_by_id(each.split("][")[2].chomp("]"))
        @failedurls << [each.split("][")[1], @album ] unless @album.nil?
      end
      @post.content.scan(/\[PASSED\]\[\d{1,5}\]/).each do |each|
        albumids << each[9..-1].chomp("]")
      end
      @albums = Album.find(albumids)
      @count = @failedurls.count + @albums.count
    end  

    def new_scrapes
      authorize! :scrape, Album
      #First we find the vgmdb album we're on. 
      post = Post.find(571)
      @number = post.content.partition(": ").last      
    end
    
    def update_scrape_number
      authorize! :scrape, Album
      #Simple method to change the post number of the record post
      post = Post.find(571)
      post.content = "Lastest VGMDB Album: " + params[:vgmdb_number][:id]
      post.save
      
      respond_to do |format|
        format.json { head :no_content }
      end 

    end

  #Workqueues
  def artist_workqueue
    authorize! :edit, Artist
    @artists = Artist.where(status: "Unreleased").order("created_at DESC").includes({artist_albums: {album: :primary_images}}).page(params[:page])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @artists }
    end
  end  
  
  def source_workqueue
    authorize! :edit, Source
    @sources = Source.where(status: "Unreleased").order('created_at DESC').includes(albums: :primary_images).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sources }
    end    
  end  
  
  def updated_albums
    authorize! :edit, Album
    @albums = Album.where("private_info LIKE ?", "#{'UPDATE AVAILABLE'}%").page(params[:page])
  end
  
  def le_workqueue
    authorize! :edit, Album
    @albums = Album.where("name LIKE ?", "%#{'Limited Edition'}%").where('id NOT IN (SELECT DISTINCT(album1_id) FROM related_albums)').includes(:related_album_relations1).page(params[:page]).per(12)
  end
  
  def released_review
    #This is basically a checklist of all the things a released record should have
    authorize! :edit, Organization
    organizations = Organization.where('status != ?', "Unreleased")
    artists = Artist.where('status != ?', "Unreleased")
    sources = Source.where('status != ?', "Unreleased")
    collection = organizations + artists + sources
    @collection = Kaminari.paginate_array(collection).page(params[:page]).per(15)
  end
  
  def released_review_drill
    #This allows you to drill down into released_review
    authorize! :edit, Organization
    @id = params[:id]
    if @id.starts_with?("S")
      source = Source.find(@id[1..-1])
      @collection = source.organizations + source.related_sources
    elsif @id.starts_with?("O")
      organization = Organization.find(@id[1..-1])
      @collection = organization.artists + organization.sources + organization.related_organizations
    elsif @id.starts_with?("A")
      artist = Artist.find(@id[1..-1])
      @collection = artist.organizations + artist.related_artists
    end    
  end
  
      
end
