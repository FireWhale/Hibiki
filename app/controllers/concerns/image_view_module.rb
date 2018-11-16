module ImageViewModule
  extend ActiveSupport::Concern

  included do
    model = self.name.chomp('sController').constantize

    define_method 'show_images' do
      @record = model.includes(:images).find_by_id(params[:id])
      if params[:image] == "cover"
        @image = @record.primary_images.first
      elsif @record.images.pluck(:id).map(&:to_s).include?(params[:image])
        @image = Image.find_by_id(params[:image])
      else
        @image = @record.images.first
      end
      @show_nws = params[:show_nws]

      respond_to do |format|
        format.html {render file: 'shared/show_images', layout: 'grid'}
        format.js { render template: "images/update_image"}
        format.json { render json: @record.images }
      end
    end

  end

end
