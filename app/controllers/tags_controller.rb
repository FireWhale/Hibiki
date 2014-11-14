class TagsController < ApplicationController
  load_and_authorize_resource
  
  def add_tag
    tag = Tag.find(params[:tag_id])
    record = params[:subject_type].constantize.find(params[:subject_id])
    
    if tag.nil? == false && record.nil? == false
      #Make sure the record is within the tag's allowed models 
      if Tag.get_models(tag.model_bitmask).include?(record.class.to_s)
        record.tags << tag
        @notice = "Successfully added tag"
        @msg = "Added"
      else
        @notice = "This tag does not go with this record class."
        @msg = "I don't how you added this, but it's an invalid tag"
      end
      @recordid = record.id
      @tagid = tag.id
    end
    
    respond_to do |format|
      format.html { redirect_to record, notice: @notice }
      format.js
    end
  end
  
  def remove_tag
    taglist = Taglist.where(:tag_id => params[:tag_id], :subject_id => params[:subject_id], :subject_type => params[:subject_type]).first
    
    if taglist.nil? == false
      taglist.delete
      @recordid = params[:subject_id]
      @tagid = params[:tag_id]
    end

    respond_to do |format|
      format.html { redirect_to record, notice: 'Successfully removed tag'}
      format.js
    end
  end

  def index
    @tags = Tag.all.sort_by { |tag| tag.classification}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags }
    end
  end

  def show
    @tag = Tag.find(params[:id])
    @models = Tag.get_models(@tag.model_bitmask)

    @tag.taglists.each do |taglist|
      if taglist.subject_type == "Album"
        (@albums ||= []) << taglist.subject
      elsif taglist.subject_type == "Artist"
        (@artists ||= []) << taglist.subject
      elsif taglist.subject_type == "Organization"
        (@organizations ||= []) << taglist.subject
      elsif taglist.subject_type == "Source"
        (@sources ||= []) << taglist.subject
      elsif taglist.subject_type == "Song"    
        (@songs ||= []) << taglist.subject    
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tag }
    end
  end

  def new
    @tag = Tag.new
    @models = Tag.get_models(@tag.model_bitmask)
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tag }
    end
  end

  def edit
    @tag = Tag.find(params[:id])
    @models = Tag.get_models(@tag.model_bitmask)
  end

  def create
    @tag = Tag.new(params[:tag])
    models = params[:tag].delete :models
    @tag.model_bitmask =  Tag.get_bitmask(models)  unless models.nil?


    respond_to do |format|
      if @tag.save
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
    models = params[:tag].delete :models
    @tag.model_bitmask =  Tag.get_bitmask(models) unless models.nil?

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
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