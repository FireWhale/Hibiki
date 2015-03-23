class PostsController < ApplicationController
  load_and_authorize_resource
  
  def show
    @post = Post.find(params[:id])
  end
  
  def index
    @posts = Post.blog_posts
    @posts = @posts.meets_security(current_user)
    @all_posts = @posts
    unless params[:tags].nil?
      @posts = @posts.has_tag(params[:tags])     
      @tags = Tag.find(params[:tags])
      @tags = [@tags] unless @tags.class == Array
    end
    @posts = @posts.order(:created_at => :desc).first(5)   
  end
  
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @album }
    end
  end
  
  def edit
    @post = Post.find(params[:id])
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
  
end
