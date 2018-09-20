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

      scrapehash = {:scrape => {}}
      raw_vgmdb_albums = params[:vgmdb_albums][:text] unless params[:vgmdb_albums].nil?


      unless raw_vgmdb_albums.blank?
        raw_vgmdb_albums.split("\n").reject { |a| a.empty?}.map { |a| a.gsub("https://","http://")}.select { |a| a.starts_with?("http://") }.each do |each|
          (scrapehash[:scrape][:vgmdb_albums] ||= []) << each.chomp("\r")
        end
      end

      scrapehash[:scrape][:vgmdb_artist_source] = params[:vgmdb_artists] unless params[:vgmdb_artists].blank?
      scrapehash[:scrape][:vgmdb_organization] = params[:vgmdb_organizations] unless params[:vgmdb_organizations].blank?

      ScrapeWorker.perform_async(scrapehash) unless scrapehash[:scrape].empty?

      respond_to do |format|
        unless scrapehash[:scrape].empty?
          format.html { redirect_to(maintenance_scrape_results_path(:log_id => (Log.last.try(:id).to_i + 1))) }
          format.json { head :no_content }
        else
          format.html { redirect_to maintenance_new_scrape_path, notice: 'No links were specified!' }
          format.json { render json: scrapehash, status: :unprocessable_entity  }
        end
      end
    end

    def scrape_results
      authorize! :scrape, Album
      if params[:log_id].blank? == false
        @log = Log.find_by_id(params[:log_id])
        @error_message = "Couldn't find Log with log_id ##{params[:log_id]}" if @log.nil?
      elsif params[:log_category].blank? == false
        @log = Log.find_last(params[:log_category])
        @error_message = "Couldn't find Log with category ##{params[:log_category]}" if @log.nil?
      end
      @log = Log.last if @log.nil?

      #Add other logs to navigation
      @log_links = {}

      @log_links["Previous #{@log.category} log"] = @log.previous_log unless @log.nil?
      @log_links["Next #{@log.category} log"] = @log.next_log unless  @log.nil?

      Log::Categories.each do |cat|
        log = Log.find_last(cat)
        @log_links["Last #{cat} log"] = log unless log.nil?
      end

      @parsed = {successful_urls: [], failed_urls: []}

      album_ids = []
      unless @log.nil? || @log.content.nil?
        @log.content.scan(/\[FAILURE\]\[[a-z0-9\.:\/]+\].+?\n/).each do |line|
          error_array = line.split("]").map { |s| s.sub(/^\[/,'')} #splits by ] and removes [ from beginning
          @parsed[:failed_urls] << "#{error_array[1]}: #{error_array[2]}"
        end
        @log.content.scan(/\[SUCCESS\]\[[a-z0-9\.:\/]+\].+?\n/).each do |line|
          success_array = line.split("]").map { |s| s.sub(/^\[/,'')} #splits by ] and removes [ from beginning
          album = @log.albums.find_by(id: success_array[1])
          @parsed[:successful_urls] << "#{album.nil? ? 'Deleted?' : album.id}: #{success_array[2]}"
        end
      end

      respond_to do |format|
        format.html
      end
    end

    def generate_urls
      authorize! :scrape, Album
      redis = Redis.new
      @number = redis.get("vgmdb_album_number")

      respond_to do |format|
        format.html
      end
    end

    def update_scrape_number
      authorize! :scrape, Album
      redis = Redis.new
      redis.set("vgmdb_album_number", params[:vgmdb_number].try(:[],:id))

      respond_to do |format|
        format.js
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
