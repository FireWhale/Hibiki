class TagsController < ApplicationController
  load_and_authorize_resource
  

  def index
    @tags = Tag.order(:classification).meets_security(current_user)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  def show
    @tag = Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tag }
    end
  end

  def new
    @tag = Tag.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tag }
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @tag }
    end
  end

  def create
    respond_to do |format|
      if @tag.full_save(params[:tag])
        format.html { redirect_to @tag, notice: 'Tag was successfully created.' }
        format.json { render json: @tag, status: :created, location: @tag }
      else
        format.html { render action: "new" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @tag = Tag.find(params[:id])
    
    respond_to do |format|
      if @tag.full_update_attributes(params[:tag])
        format.html { redirect_to @tag, notice: 'Tag was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tag.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to tags_url }
      format.json { head :no_content }
    end
  end
end
