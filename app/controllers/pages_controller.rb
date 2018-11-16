class PagesController < ApplicationController
  layout "grid", only: [:calendar]

  def front_page
    authorize! :read, Album

    @posts = Post.with_category("Blog Post").meets_role(current_user).order(:id => :desc).includes(:tags).first(5)
    @albums = Album.filter_by_user_settings(current_user).order(Arel.sql("RAND()")).includes(:primary_images, :translations).first(8).shuffle

    respond_to do |format|
      format.html
    end
  end

  def help
    authorize! :read, Album

    respond_to do |format|
      format.html
    end
  end

  def calendar
    authorize! :read, Album

    respond_to do |format|
      format.html
    end
  end

  def random_albums #Just a fun side-project to display
    authorize! :read, Album

    album_count = [(params[:count] || 100).to_i, 250].min #a maximum of 250 albums will be allowed
    @albums = Album.filter_by_user_settings(current_user).order("RAND()").includes(:primary_images).first(album_count).shuffle
    @slice = (@albums.count / 6.0).ceil

    respond_to do |format|
      format.html
      format.json { render json: @albums.to_json(:user => current_user)}
    end
  end

  def search
    authorize! :read, Album

    @query = truncate(params[:search], length: 50, escape: false) #used in html

    if %w(album artist source organization song).include?(params[:model])
      @records = PrimaryRecordGetter.perform('search', query: params[:search], model: params[:model], current_user: current_user, page: params[:page]).results
      @model = params[:model]
    end

    respond_to do |format|
      format.html do
        @counts = {}
        %w(album artist source organization song).each do |model|
          @counts[model.to_sym] = PrimaryRecordCounter.perform('search', query: params[:search], model: model, current_user: current_user)
        end
        if @model.blank?
          if @counts[:album] > 0
            @records = PrimaryRecordGetter.perform('search', query: params[:search], model: 'album', current_user: current_user, page: params[:page]).results
            @model = 'album'
          elsif @counts[:artist] > 0
            @records = PrimaryRecordGetter.perform('search', query: params[:search], model: 'artist', current_user: current_user, page: params[:page]).results
            @model = 'artist'
          elsif @counts[:source] > 0
            @records = PrimaryRecordGetter.perform('search', query: params[:search], model: 'source', current_user: current_user, page: params[:page]).results
            @model = 'source'
          elsif @counts[:organization] > 0
            @records = PrimaryRecordGetter.perform('search', query: params[:search], model: 'organization', current_user: current_user, page: params[:page]).results
            @model = 'organization'
          elsif @counts[:song] > 0
            @records = PrimaryRecordGetter.perform('search', query: params[:search], model: 'song', current_user: current_user, page: params[:page]).results
            @model = 'song'
          end
        end
      end
      format.js
      format.json
    end

  end

  def forgotten_password
    authorize! :forgotten_password, User

    respond_to do |format|
      format.html
    end
  end


  def request_password_reset_email
    authorize! :request_password_reset_email, User

    @user = User.find_by_email(params[:email])
    @user.deliver_password_reset_instructions! unless @user.nil?

    respond_to do |format|
      #Reusing the forgotten_password_path so I don't have to add a route and controller method
      format.html { redirect_to forgotten_password_path, notice: "Thank you! An email has been sent to #{truncate(params[:email], length: 50)} with instructions to recover your password. If you do not receive an email, please contact support."  }
      format.json { head :no_content }
    end
  end

  def reset_password_page
    authorize! :reset_password_page, User
    @token = params[:token]
    @user = User.find_using_perishable_token(@token)

    respond_to do |format|
      format.html
    end
  end

  def reset_password
    authorize! :reset_password, User
    @user = User.find_using_perishable_token(params[:user][:token])

    unless @user.nil?
      #I'm probably fixing this the wrong way, but:
      @user.password = "invalid"
      @user.valid?
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      @token = params[:user][:token]
    end

    respond_to do |format|
      if @user.nil? #Not a valid token
        format.html { redirect_to :root }
        format.json { render json: {}, status: :unprocessable_entity }
      else
        if @user.save
          format.html { redirect_to :root }
          format.json { head :no_content }
        else
          format.html { render action: 'reset_password_page', notice: 'Failed to reset password' }
          format.json { render json: @user.errors.to_hash.except!(:crypted_password, :password_salt), status: :unprocessable_entity }
        end
      end
    end
  end

end
