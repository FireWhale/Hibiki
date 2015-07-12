class PostsController < ApplicationController
  load_and_authorize_resource
  layout "grid", only: [:show_images]
  
  def index
    @posts = Post.includes(:tags).with_category('Blog Post').meets_security(current_user)
    @all_posts = @posts
    unless params[:tags].nil?
      @posts = @posts.with_tag(params[:tags])     
      @tags = Tag.find(params[:tags])
      @tags = [@tags] unless @tags.class == Array
    end
    @posts = @posts.order(:id => :desc).page(params[:page])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end
   
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  def show_images
    @post = Post.includes(:images).find_by_id(params[:id])
    if params[:image] == "cover"
      @image = @post.primary_images.first
    elsif @post.images.map(&:id).map(&:to_s).include?(params[:image])
      @image = Image.find_by_id(params[:image])
    else
      @image = @post.images.first
    end
    @show_nws = params[:show_nws]

    respond_to do |format|
      format.html 
      format.js { render template: "images/update_image"}
      format.json { render json: @post.images }
    end
  end
    
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @post }
    end
  end
  
  def edit
    @post = Post.find(params[:id])
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @post }
    end
  end
    
  def create
    respond_to do |format|
      if @post.full_save(params[:post])
        format.html { redirect_to @post, notice: 'Post Created!' }
        format.json { render json: @post, status: :created, location: @post }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end 
    end
  end
  
  def update
    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.full_update_attributes(params[:post])
        format.html { redirect_to @post, notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
    
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end
  
end
