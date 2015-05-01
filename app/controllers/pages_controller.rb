class PagesController < ApplicationController
    
  def front_page
    authorize! :read, Album
    
    @posts = Post.with_category("Blog Post").meets_security(current_user).order(:id => :desc).first(5)
    @albums = Album.filter_by_user_settings(current_user).order("RAND()").includes(:primary_images).first(8).shuffle
    
    respond_to do |format|
      format.html
    end
  end

  def help
    authorize! :read, Album
    
    respond_to do |format|
      format.html
    end
  end
  
  def calendar
    authorize! :read, Album
    
    respond_to do |format|
      format.html
    end
  end
  
  def random_albums #Just a fun side-project to display   
    authorize! :read, Album
    
    album_count = [(params[:count] || 100).to_i, 250].min #a maximum of 250 albums will be allowed
    @albums = Album.filter_by_user_settings(current_user).order("RAND()").includes(:primary_images).first(album_count).shuffle
    @slice = (@albums.count / 6.0).ceil
    
    respond_to do |format|
      format.html
      format.json { render json: @albums}
    end
  end  
   
  def search
    authorize! :read, Album
    @query = truncate(params[:search], length: 50) #used in html
    @model = (params[:model].nil? ? nil : params[:model]) #for JS
    @records = nil
    @search = {:search => @query, :utf8 => params[:utf8]} #used
    
    respond_to do |format|
      format.html { @models = ["album", "artist", "source", "organization", "song"]}
      format.js { @models = (@model.nil? ? ["album", "artist", "source", "organization", "song"] : [@model])}
    end
    
    @models.each do |model|
      #set up eager loading hash
      includes = [:tags]
      if model == "artist" || model == "organization" || model == "source"
        includes.push(:watchlists)
        #don't include albums. we only need the first 5 of them + count
      elsif model == "song"
        includes.push(album: :primary_images)
      elsif model == "album"
        includes.push(:primary_images)
      end
      search = model.capitalize.constantize.search(:include => includes) do
        fulltext params[:search]
        order_by(:release_date) if model == "album"
        paginate :page => params["#{model}_page".to_sym]
      end      
      instance_variable_set("@#{model}_count", search.total)
      if search.total > 0 && @model.nil?
        @model = model
      end
      @records = search.results if @model == model && @records.nil? 
    end
    @model = "any cateogorie" if @model.nil? #text for if there were no results at all
  end 
   
  

end
