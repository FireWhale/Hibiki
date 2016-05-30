class TagsController < ApplicationController
  load_and_authorize_resource
  

  def index
    @tags = Tag.order(:classification).meets_security(current_user)
    
    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def show
    @tag = Tag.find(params[:id])
        
    @records = Kaminari.paginate_array(@tag.subjects).page(params[:record_page]).per(30)
    
    respond_to do |format|
      format.html # show.html.erb
      format.json {@fields = (params[:fields] || '').split(',')}
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
    @tag = Tag.new(tag_params)
    
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
    
    respond_to do |format|
      if @tag.update_attributes(tag_params)
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
  
  class TagParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:tag).permit(:internal_name,:classification, :visibility, :tag_models => [],
                                    :new_name_langs => [], :new_name_lang_categories => [], :name_langs => params[:tag][:name_langs].try(:keys),
                                    :new_info_langs => [], :new_info_lang_categories => [], :info_langs => params[:tag][:info_langs].try(:keys))
      elsif current_user
        params.require(:tag).permit()
       else
        params.require(:tag).permit()
      end     
    end
  end
  
  private
    def tag_params
      TagParams.filter(params,current_user)
    end
end