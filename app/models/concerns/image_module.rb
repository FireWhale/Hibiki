module ImageModule
  extend ActiveSupport::Concern

  included do
    has_many :imagelists, dependent: :destroy, as: :model
    has_many :images, through: :imagelists
    has_many :primary_images, -> {where "images.primary_flag <> ''" }, through: :imagelists, source: :image

    attr_accessor :new_images

    after_save :add_images
  end

  private
    def add_images
      unless self.new_images.blank?
        self.new_images.each do |image_info|
          image_info = {image: image_info} unless image_info.is_a?(Hash) #Converts simple images into a hash
          full_dir_path = "#{Rails.application.secrets.image_directory}/#{self.class.model_name.plural}/#{self.id}"
          Dir.mkdir(full_dir_path) unless File.exists?(full_dir_path)
          mini_image = MiniMagick::Image.read(image_info[:image].read)
          extension = mini_image.type.downcase
          extension = 'jpg' if extension == 'jpeg' #replace jpeg with jpg
          file_name = image_info[:image].original_filename.strip #with file extension
          file_name = file_name[0..-(mini_image.type.length + 2)] if file_name.downcase.ends_with?(mini_image.type.downcase)
          record_image_paths = self.images.map(&:path)
          original_name = file_name
          i = 1
          while record_image_paths.include?("#{self.class.model_name.plural}/#{self.id}/#{file_name}.#{extension}")
            file_name = original_name + " #{i}"
            i += 1
          end
          attributes = generate_attributes(image_info,file_name,extension)
          #Finally, create an image record and add the image to the instance.
          unless attributes[:name].blank? || attributes[:path].blank?
            mini_image.write(Rails.root.join(Rails.application.secrets.image_directory,attributes[:path]))
            self.images << Image.create(attributes)
          end
          self.new_images = nil
        end
      end
    end

    def generate_attributes(image_info,file_name,extension)
      attributes_hash = {name: image_info[:image_name] || file_name } #defaults to file_name if not provided
      attributes_hash[:path] = "#{self.class.model_name.plural}/#{self.id}/#{file_name}.#{extension}"
      attributes_hash[:primary_flag] = image_info[:primary_flag] || (self.images.empty? ? 'Primary' : '')
      attributes_hash[:rating]  = 'NWS' unless image_info[:nws_flag].blank?
      return attributes_hash
    end

end
