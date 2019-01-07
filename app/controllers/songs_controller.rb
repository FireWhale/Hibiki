class SongsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :create
  include ImageViewModule
  layout "full", only: [:edit, :new]

  def index
    @records = PrimaryRecordGetter.perform('index',model: 'song', page: params[:page])

    respond_to do |format|
      format.html {render file: 'shared/index' }
      format.json {render file: 'shared/index'}
    end
  end

  def show
    @record = Song.includes(:translations).find(params[:id])
    
    self_relation_helper(@record,@related = {}) #Prepare @related (self_relations)
    credits_helper(@record,@credits = {}) #prepares the credits
        
    respond_to do |format|
      format.html do
        if @record.album.nil?
          render file: 'shared/show'
        else
          redirect_to album_path(id: @record.album.id, :anchor => "song-#{@record.id}")
        end
      end
      format.json do
        @fields = (params[:fields] || '').split(',')
        @fields << 'full_song_info' unless params[:full_song_info].blank?
        render file: 'shared/show'
      end
    end
  end


  def new
    @form = SongForm.new

    respond_to do |format|
      format.html  { render file: 'shared/new', layout: 'full'}
      format.json { render json: @form }
    end
  end


  def edit
    @record = Song.find(params[:id])
    @form = SongForm.new(record: @record)
    
    respond_to do |format|
      format.html { render file: 'shared/edit', layout: 'full'}
      format.json { render json: @form }
    end
  end

  def create
    @form = SongForm.new(song_params)

    respond_to do |format|
      if @form.save
        NeoWriter.perform(@form.record,1)
        format.html { redirect_to @form.record, notice: "#{@form.record.class} was successfully created." }
        format.json { render json: @form.record, status: :created, location: @form.record }
      else
        format.html { render action: 'new', file: 'shared/new', layout: 'full' }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @form = SongForm.new(song_params.merge(record: Song.find(params[:id])))

    respond_to do |format|
      if @form.save
        NeoWriter.perform(@form.record,1)
        format.html { redirect_to @form.record, notice:  "#{@form.record.class} was successfully updated." }
        format.json { head :no_content }
      else
        @record = @form.record.class.find(params[:id])
        format.html { render action: 'edit', file: 'shared/edit', layout: 'full' }
        format.json { render json: @form.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @song = Song.find(params[:id])
    @song.destroy

    respond_to do |format|
      format.html { redirect_to songs_url }
      format.json { head :no_content }
    end
  end
  
  class SongParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:song_form).permit!
      elsif current_user
        params.require(:song_form).permit()
      else
        params.require(:song_form).permit()
      end             
    end
  end
  
  private
    def song_params
      SongParams.filter(params,current_user)
    end
end
