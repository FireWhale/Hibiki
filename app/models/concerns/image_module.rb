module ImageModule
  extend ActiveSupport::Concern

  included do
    has_many :imagelists, dependent: :destroy, as: :model
    has_many :images, through: :imagelists
    has_many :primary_images, -> {where "images.primary_flag <> ''" }, through: :imagelists, source: :image

    attr_accessor :new_images
    attr_accessor :image_names
    attr_accessor :image_paths

    after_save :add_images
    after_save :add_image_paths
  end

  private
    def add_images
      unless new_images.blank?
        new_images.each do |image|
          full_dir_path = "#{Rails.application.secrets.image_directory}/#{self.class.model_name.plural}/#{self.id}"
          Dir.mkdir(full_dir_path) unless File.exists?(full_dir_path)
          image_name = image.original_filename.strip
          mini_image = MiniMagick::Image.read(image.read)
          image_name = image_name[0..-(mini_image.type.length + 2)] if image_name.downcase.ends_with?(mini_image.type.downcase)
          original_name = image_name
          record_image_names = self.images.map(&:name)
          i = 1
          while record_image_names.include?(image_name)
            image_name = original_name + " #{i}"
            i += 1
          end
          full_path = Rails.root.join(full_dir_path,image_name)
          mini_image.write(full_path)
          image_path = "#{self.class.model_name.plural}/#{self.id}/#{image_name}"
          priflag = (self.images.empty? ? (self.class == Album ? "Cover" : "Primary") : '')
          #Finally, create an image record and add the image to the instance.
          unless image_name.blank? || image_path.blank?
            self.images << Image.create(name: image_name, path: image_path, primary_flag: priflag)
          end
          self.new_images = nil
        end
      end
    end

    def add_image_paths #Adds an image record for existing images.
      #For scraping, so one doesn't have to send the image itself, just names/paths
      unless image_names.blank? || image_paths.blank?
        image_names.zip(image_paths).each do |each|
          unless each[0].empty? || each[1].empty?
            priflag = (self.images.empty? ? 'Cover' : '')
            self.images << Image.create(name: each[0], path: each[1], primary_flag: priflag)
          end
        end
      end
    end
end
