class MaintenanceController < ApplicationController

  def index
    authorize! :edit, Album

    respond_to do |format|
      format.html
    end
  end

  #Scrapes
    def new_scrape
      authorize! :scrapepage, Album

      respond_to do |format|
        format.html
      end
    end

    def scrape
      authorize! :scrape, Album

      scrapehash = {}
      vgmdb_albums = []
      raw_vgmdb_albums = params[:vgmdb_albums][:text] unless params[:vgmdb_albums].nil?
      unless raw_vgmdb_albums.nil?
        raw_vgmdb_albums.split("\n").reject { |a| a.empty?}.select { |a| a.starts_with?("http://") }.each do |each|
          (scrapehash[:vgmdb_albums] ||= []) << each.chomp("\r")
        end
      end
      scrapehash[:vgmdb_albums] = vgmdb_albums unless vgmdb_albums.empty?
      scrapehash[:vgmdb_artists] = params[:vgmdb_artists] unless params[:vgmdb_artists].nil? || params[:vgmdb_artists] == [""]
      scrapehash[:vgmdb_organizations] = params[:vgmdb_organizations] unless params[:vgmdb_organizations].nil? || params[:vgmdb_organizations] == [""]
      scrapehash[:cdjapan_albums] = params[:cdjapan_albums] unless params[:cdjapan_albums].nil? || params[:cdjapan_albums] == [""]
      scrapehash[:manifo_albums] = params[:manifo_albums] unless params[:manifo_albums].nil? || params[:manifo_albums] == [""]

      unless scrapehash.empty?
        postmessage = "Scrape started at " + Time.now.to_s + " with inputs: "
        scrapehash.each do |k,v|
          postmessage << "\n\n#{k.to_s.humanize}:"
          v.each {|link| postmessage << "\n"  + link}
        end

        @post = Post.create(category: "Scrape Result", status: "Released", visibility: "Scraper", content: postmessage)
        ScrapeWorker.perform_async(scrapehash,@post.id)
      end

      respond_to do |format|
        unless @post.nil?
          format.html { redirect_to(maintenance_scrape_results_path(:post_id => @post.id)) }
          format.json { head :no_content }
        else
          format.html { redirect_to maintenance_new_scrape_path, notice: 'No links were specified!' }
          format.json { render json: scrapehash, status: :unprocessable_entity  }
        end
      end
    end

    def scrape_results
      authorize! :scrape, Album
      unless params[:post_id].nil?
        @post = Post.find(params[:post_id])
      else
        @post = Post.with_category(["Scrape Result", "Rescrape Result"]).last
      end

      album_ids = []
      @failedurls = []
      @duplicate_albums = []
      unless @post.nil? || @post.content.nil?
        @post.content.force_encoding("UTF-8")
        @post.content.scan(/\[FAILED\]\[[a-z0-9\.:\/]+\]\[\d{1,5}\]/).each do |each|
          album = Album.find_by_id(each.split("][")[2].chomp("]"))
          @duplicate_albums << [each.split("][")[1], album ] unless album.nil?
          @failed_urls << each.split("][")[1] if album.nil?
        end
        @post.content.scan(/\[PASSED\]\[\d{1,5}\]/).each do |each|
          album_ids << each[9..-1].chomp("]")
        end
      end
      @albums = Album.find(album_ids)
      @count = @failedurls.count + @albums.count + @duplicate_albums.count

      respond_to do |format|
        format.html
      end
    end

    def generate_urls
      authorize! :scrape, Album
      #First we find the vgmdb album we're on.
      post = Post.find(571)
      @number = post.content.partition(": ").last

      respond_to do |format|
        format.html
      end
    end

    def update_scrape_number
      authorize! :scrape, Album
      #Simple method to change the post number of the record post
      @post = Post.find(571)
      @post.content = "Lastest VGMDB Album: " + params[:vgmdb_number][:id] unless params[:vgmdb_number].nil?
      @post.save

      respond_to do |format|
        format.html { head :no_content }
        format.json { head :no_content }
      end
    end

  #Workqueues
  def artist_workqueue
    authorize! :edit, Artist
    @artists = Artist.where(status: "Unreleased").order("id DESC").includes(:watchlists, :tags, albums: :primary_images).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @artists }
    end
  end

  def source_workqueue
    authorize! :edit, Source
    @sources = Source.where(status: "Unreleased").order('id DESC').includes(:watchlists, :tags, albums: :primary_images).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sources }
    end
  end

  def organization_workqueue
    authorize! :edit, Organization
    @organizations = Organization.with_status("Unreleased").order('id DESC').includes(:watchlists, :tags, albums: :primary_images).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organizations }
    end
  end

  def update_available_albums
    authorize! :edit, Album
    @albums = Album.where("private_info LIKE ?", "#{'UPDATE AVAILABLE'}%").page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @albums }
    end
  end

  def le_workqueue
    authorize! :edit, Album
    @albums = Album.where("name LIKE ?", "%#{'Limited Edition'}%").where('id NOT IN (SELECT DISTINCT(album1_id) FROM related_albums)').includes(:related_album_relations1).page(params[:page]).per(12)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @albums }
    end
  end

  def released_review
    #This is basically a checklist of all the things a released record should have
    authorize! :edit, Organization
    organizations = Organization.where('status != ?', "Unreleased")
    artists = Artist.where('status != ?', "Unreleased")
    sources = Source.where('status != ?', "Unreleased")
    aos = organizations + artists + sources
    @aos = Kaminari.paginate_array(aos).page(params[:page]).per(15)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @aos }
    end
  end

  def released_review_drill
    #This allows you to drill down into released_review
    authorize! :edit, Organization
    @id = params[:id]
    if @id.starts_with?("S")
      source = Source.find(@id[1..-1])
      @aos = source.organizations + source.related_sources
    elsif @id.starts_with?("O")
      organization = Organization.find(@id[1..-1])
      @aos = organization.artists + organization.sources + organization.related_organizations
    elsif @id.starts_with?("A")
      artist = Artist.find(@id[1..-1])
      @aos = artist.organizations + artist.related_artists
    end

    respond_to do |format|
      format.js
    end
  end


end
