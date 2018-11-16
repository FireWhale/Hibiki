module GenViewsModule
  extend ActiveSupport::Concern

  included do
    model = self.name.chomp('sController').constantize

    define_method 'show' do
      @record = model.includes(:watchlists, :translations, :primary_images).find(params[:id])
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
      @records = PrimaryRecordGetter.perform('index',model: model.class_name.downcase, page: params[:page])

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

  end

end
