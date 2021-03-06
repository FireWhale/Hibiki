class PostsController < ApplicationController
  load_and_authorize_resource
  include ImageViewModule
  layout "grid", only: [:show_images]
  
  def index
    @posts = Post.includes(:tags).with_category('Blog Post').meets_role(current_user)
    @all_posts = @posts
    unless params[:tags].nil?
      @posts = @posts.with_tag(params[:tags])     
      @tags = Tag.find(params[:tags])
      @tags = [@tags] unless @tags.class == Array
    end
    @posts = @posts.order(:id => :desc).page(params[:page])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end
   
  def show
    @post = Post.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.js {@id = @post.id}
      format.json {@fields = (params[:fields] || '').split(',')}
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
    @post = Post.new(post_params)
    
    respond_to do |format|
      if @post.save
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
      if @post.update_attributes(post_params)
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
  
  class PostParams    
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:post).permit(:title, :content, :status, :visibility, :category, :new_images => [])
      elsif current_user
        params.require(:post).permit()
      else
        params.require(:post).permit()
      end     
    end
  end
  
  private
    def post_params
      PostParams.filter(params,current_user)
    end  
end
