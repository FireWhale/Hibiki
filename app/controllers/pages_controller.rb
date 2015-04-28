class PagesController < ApplicationController
    
  def front_page
    @posts = Post.with_category("Blog Post").meets_security(current_user).order(:created_at => :desc).first(5)
    @albums = Album.order("RAND()").includes(:primary_images).first(8).shuffle
  end

  def help
    
  end
   
  def search
    authorize! :read, Album
    @query = truncate(params[:search], length: 400)
    @model = (params[:model].nil? ? nil : params[:model]) 
    @records = nil
    @search = {:search => @query, :utf8 => params[:utf8]}
    
    respond_to do |format|
      format.html { @models = ["album", "artist", "source", "organization", "song"]}
      format.js { @models = (@model.nil? ? ["album", "artist", "source", "organization", "song"] : [@model])}
    end
    
    @models.each do |model|
      #set up eager loading hash
      includes = [:tags]
      if model == "artist" || model == "organization" || model == "source"
        includes.push(:watchlists)
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
      @records = search.results if @model == model && @reccrds.nil? 
    end
    @model = "any cateogorie" if @model.nil? #text for if there were no results at all
  end 
   
  def calendar
    authorize! :read, Album
    respond_to do |format|
      format.html
    end
  end
  
  
  def randomalbums #Just a fun side-project to display   
    authorize! :read, Album
    
    @numberofalbums = 100
    @slice = (@numberofalbums / 6.0).ceil
    @albums= Album.order("RAND()").includes(:primary_images).first(@numberofalbums).shuffle
  end  

end
