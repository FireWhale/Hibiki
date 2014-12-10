class PostsController < ApplicationController
  load_and_authorize_resource
  
  def show
    @post = Post.find(params[:id])
  end
  
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @album }
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
  

  
end
