class SongsController < ApplicationController
  load_and_authorize_resource

  autocomplete :song, :namehash, :full => true, :extra_data => [:name], :display_value => :format_method  

  def index
    @songs = Song.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @songs }
    end
  end

  def show
    @song = Song.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @song }
    end
  end

  def new
    @song = Song.new
    @song.namehash = @song.namehash || {}


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @song }
    end
  end

  def edit
    @song = Song.find(params[:id])
  end

  def create
    respond_to do |format|
      if @song.full_save(params[:song])
        format.html { redirect_to @song, notice: 'Song was successfully created.' }
        format.json { render json: @song, status: :created, location: @song }
      else
        format.html { render action: "new" }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @song = Song.find(params[:id])

    respond_to do |format|
      if @song.full_update_attributes(params[:song])
        format.html { redirect_to @song, notice: 'Song was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @song.errors, status: :unprocessable_entity }
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
end
