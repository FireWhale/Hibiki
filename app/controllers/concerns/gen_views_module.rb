module GenViewsModule
  extend ActiveSupport::Concern

  included do
    model = self.name.chomp('sController').constantize

    define_method 'show' do
      @record = model.includes(:watchlists, :translations, :primary_images).find(params[:id])
      #TODO Remove @record and everything and put in hash
      self_relation_helper(@record,@related = {}) #Prepare @related (self_relations)

      @albums = @record.albums.includes(:primary_images, :tags, :translations).filter_by_user_settings(current_user).order('release_date DESC').page(params[:album_page])

      respond_to do |format|
        format.js {render file: 'shared/show' }
        format.html {render file: 'shared/show' }
        format.json do
          @fields = (params[:fields] || '').split(',')
          render file: 'shared/show'
        end
      end
    end

    define_method 'index' do
      @records = model.order(:internal_name).includes(:watchlists, :translations, :tags, :albums).page(params[:page])

      respond_to do |format|
        format.html {render file: 'shared/index' }
        format.json {render file: 'shared/index'}
      end
    end

    define_method 'new' do
      @record = model.new
      @record.namehash ||= {}

      respond_to do |format|
        format.html  { render file: 'shared/new', layout: 'full'}
        format.json { render json: @record }
      end
    end

    define_method 'edit' do
      @record = model.find(params[:id])
      @record.namehash ||= {}

      respond_to do |format|
        format.html { render file: 'shared/edit', layout: 'full'}
        format.json { render json: @record }
      end
    end

    define_method 'show_images' do
      @record = model.includes(:images).find_by_id(params[:id])
      if params[:image] == "cover"
        @image = @record.primary_images.first
      elsif @record.images.map(&:id).map(&:to_s).include?(params[:image])
        @image = Image.find_by_id(params[:image])
      else
        @image = @record.images.first
      end
      @show_nws = params[:show_nws]

      respond_to do |format|
        format.html {render file: 'shared/show_images', layout: 'grid'}
        format.js { render template: "images/update_image"}
        format.json { render json: @record.images }
      end
    end


  end

end
