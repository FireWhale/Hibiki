class Image < ApplicationRecord

  #Concerns
  include JsonModule

  attr_accessor :_destroy

  #Callbacks/Hooks
    before_destroy :delete_images
    after_save :create_image_thumbnails

  #Constants
    Rating = ["NWS", "SFW"]
    PrimaryFlags = ["Cover", "Primary"]

    FormFields = [{type: "text", attribute: :name, label: "Name:", field_class: "input-xlarge"},
                  {type: "select", attribute: :primary_flag,label: "Primary flag:", categories: Image::PrimaryFlags},
                  {type: "select", attribute: :rating, label: "NWS/SFW:", categories: Image::Rating},
                  {type: "info", attribute: :llimagelink, label: "ETI Image Link:", field_class: "input-xlarge"},
                  {type: "info", attribute: :path, label: "Path:", field_class: "input-xlarge"},
                  {type: "info", attribute: :medium_path, label: "Medium Path:", field_class: "input-xlarge"},
                  {type: "info", attribute: :thumb_path, label: "Thumb Path:", field_class: "input-xlarge"},
                  {type: "info", attribute: :width, label: "Width:"},
                  {type: "info", attribute: :height, label: "Height:"},
                  {type: "info", attribute: :medium_width, label: "Medium Width:"},
                  {type: "info", attribute: :medium_height, label: "Medium Height:"},
                  {type: "info", attribute: :thumb_width, label: "Thumb Width:"},
                  {type: "info", attribute: :thumb_height, label: "Thumb Height:"}]

  #Validation
    validates :name, presence: true
    validates :path, presence: true
    validates :rating, inclusion: Image::Rating, allow_blank: true, allow_nil: true

  #Associations
    has_many :imagelists, dependent: :destroy
    has_many :albums, through: :imagelists, source: :model, source_type: 'Album'
    has_many :artists, through: :imagelists, source: :model, source_type: 'Artist'
    has_many :organizations, through: :imagelists, source: :model, source_type: 'Organization'
    has_many :sources, through: :imagelists, source: :model, source_type: 'Source'
    has_many :songs, through: :imagelists, source: :model, source_type: 'Song'
    has_many :users, through: :imagelists, source: :model, source_type: 'User'
    has_many :posts, through: :imagelists, source: :model, source_type: 'Post'
    has_many :seasons, through: :imagelists, source: :model, source_type: 'Season'

    def models
      imagelists.map(&:model)
    end

    def model
      models.first
    end

  #Scopes
    scope :primary_images, -> { where("primary_flag <> ''")}

  #Gem Stuff
    #Pagination
    paginates_per 50


  #Callback Methods
    def delete_images
      #if a path isn't empty, see if the file exists and delete it.
      ["medium_path","thumb_path","path"].each do |p|
        if self.send("#{p}?")
          full_path = "#{Rails.application.secrets.image_directory}/#{self.send(p)}"
          FileUtils.remove_file(Rails.root.join(full_path), true) if File.exists?(full_path)
          #If a folder is empty, remove it
            folder_path = full_path.split("/")
            folder_path.pop
            folder_path = folder_path.join("/")
            if File.exists?(folder_path) && Dir.entries(folder_path).count <= 3
              #Remove Thumbs.db if it exists <--- relevant in windows only
                if File.exists?(folder_path + "/Thumbs.db")
                  FileUtils.remove_file(Rails.root.join(folder_path + "/thumbs.db"))
                end
              #Remove the dir
                if Dir.entries(folder_path).count == 2 #<-- on linux I can just do this
                  FileUtils.remove_dir(Rails.root.join(folder_path))
                end
            end
        end
      end
    end

    def create_image_thumbnails
      root_path = Rails.root.join(Rails.application.secrets.image_directory,self.path).to_s
      if File.exist?(root_path)
        #Grab the file
        buffer = StringIO.new(File.open(root_path,"rb") { |f| f.read})
        mini_image = MiniMagick::Image.read(buffer)
        #Get the extension of the file.
        extension = mini_image.type.downcase
        extension = "jpg" if extension == "jpeg" #replace jpeg with jpg
        #update height and width of the image.
        self.height = mini_image.height
        self.width = mini_image.width
        #Make a medium size.
        if (mini_image.width > 500 || mini_image.height > 500) && (primary_flag.blank? == false)
          self.make_image(mini_image, "500x500", "/m", "medium", extension)
        end
        #Make a thumbnail image if it satisfies requirements
        if mini_image.height > 225 || mini_image.width > 225
          self.make_image(mini_image, "225x225", "/t", "thumb", extension)
        end
        #Add a file extension
        unless root_path.to_s.ends_with?(extension)
          self.path = "#{self.path}.#{extension}"
          File.rename(root_path,"#{root_path}.#{extension}")
        end
        #Remove the extension from the image's name
        self.name = self.name.chomp(".#{extension}") if self.name.ends_with?(".#{extension}")
        #Save if the info has changed. Skipping the callback to avoid infinite recursion.
        Image.skip_callback(:save, :after, :create_image_thumbnails)
        self.save
        Image.set_callback(:save, :after, :create_image_thumbnails)
      end
    end

    def make_image(image, size, subdirectory, attribute, extension)
      #Set up all sorts of variables messing around with path
        full_path = "#{Rails.application.secrets.image_directory}/#{path}".split("/")
        filename = full_path.pop
        new_path = full_path.join("/") + subdirectory
        Dir.mkdir(new_path) unless File.exists?(new_path)
        new_full_path = Rails.root.join(new_path,filename)
        if filename.ends_with?(extension)
          new_full_path_with_extension = Rails.root.join(new_path,filename)
          stored_path = new_path.split("#{Rails.application.secrets.image_directory}/")[1] + "/#{filename}"
        else
          new_full_path_with_extension = Rails.root.join(new_path,"#{filename}.#{extension}")
          stored_path = new_path.split("#{Rails.application.secrets.image_directory}/")[1] + "/#{filename}.#{extension}"
        end
      #Check to see if the file exists or dimensions are not stored
        image.resize size
        if File.exists?(new_full_path)
          File.rename(new_full_path.to_s,new_full_path_with_extension.to_s) #we need to rename it if the extensionless file exists
        else
          image.write(new_full_path_with_extension) unless File.exists?(new_full_path_with_extension)
        end
        self.send("#{attribute}_width=", image.width)
        self.send("#{attribute}_height=", image.height)
      #If the path isn't right, update it
        self.send("#{attribute}_path=", stored_path)
    end
end
