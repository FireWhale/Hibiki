class Image < ActiveRecord::Base
  #Attributes
    attr_accessible :name, :path, :medium_path, :thumb_path, 
                    :width, :height, :thumb_width, :thumb_height,
                    :medium_width, :medium_height,
                    :rating, :llimagelink, :primary_flag

  #Concerns
    include JsonModule
    
  #Callbacks/Hooks
    before_destroy :delete_images
    after_save :create_image_thumbnails
  
  #Constants
    Rating = ["NWS", "SFW"] 
    PrimaryFlags = ["Cover", "Primary"]
    
    FormFields = [{type: "markup", tag_name: "div class='col-md-1'"},{type: "markup", tag_name: "/div"},
                  {type: "markup", tag_name: "div class='col-md-11'"},
                  {type: "text", attribute: :name, label: "Name:", field_class: "input-xlarge"},
                  {type: "select", attribute: :primary_flag,label: "Primary flag:", categories: Image::PrimaryFlags},
                  {type: "select", attribute: :rating, label: "NWS/SFW:", categories: Image::Rating},
                  {type: "text", attribute: :llimagelink, label: "ETI Image Link:", field_class: "input-xlarge"},
                  {type: "text", attribute: :path, label: "Path:", field_class: "input-xlarge"},
                  {type: "text", attribute: :medium_path, label: "Medium Path:", field_class: "input-xlarge"},
                  {type: "text", attribute: :thumb_path, label: "Thumb Path:", field_class: "input-xlarge"},
                  {type: "text", attribute: :width, label: "Width:", no_div: true},
                  {type: "text", attribute: :height, label: "Height:", no_div: true},
                  {type: "text", attribute: :medium_width, label: "Medium Width:", no_div: true},
                  {type: "text", attribute: :medium_height, label: "Medium Height:", no_div: true},
                  {type: "text", attribute: :thumb_width, label: "Thumb Width:", no_div: true},
                  {type: "text", attribute: :thumb_height, label: "Thumb Height:", no_div: true},
                  {type: "markup", tag_name: "/div"},
                  {type: "markup", tag_name: "div class='col-md-1'"},{type: "markup", tag_name: "/div"},]
    
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
          full_path = "public/images/" + self.send(p)
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
      root_path = Rails.root.join('public', 'images', path).to_s
      if File.exist?(root_path)
        #Get the file
        buffer = StringIO.new(File.open(root_path,"rb") { |f| f.read})
        miniimage = MiniMagick::Image.read(buffer) 
        #We're also going to add dimensions to the record while we're at it.
        self.update_attribute('width', miniimage["width"]) unless self.width == miniimage["width"]
        self.update_attribute('height', miniimage["height"]) unless self.height == miniimage["height"]
        #Make a medium image if it satisfies requirements
          if (miniimage["width"] > 500 || miniimage["height"] > 500) & 
          (primary_flag.nil? == false && primary_flag.empty? == false)        
            self.make_image(miniimage, "500x500", "/m", "medium")
          end
        #Make a thumbnail image if it satisfies requirements
          if miniimage["height"] > 225 || miniimage["width"] > 225
            self.make_image(miniimage, "225x225", "/t", "thumb")
          end
      end    
    end
  
    def make_image(image, size, subdirectory, attribute)
      #Set up all sorts of variables messing around with path
        full_path = ('public/images/' + path).split("/")
        filename = full_path.pop
        new_path = full_path.join("/") + subdirectory
        Dir.mkdir(new_path) unless File.exists?(new_path)
        new_full_path = Rails.root.join(new_path,filename)
        stored_path = new_path.split("public/images/")[1] + "/" + filename
      #Check to see if the file exists or dimensions are not stored        
        image.resize size
        image.write(new_full_path) unless File.exists?(new_full_path)
        self.update_attribute("#{attribute}_width", image["width"]) unless self.send("#{attribute}_width") ==  image["width"]
        self.update_attribute("#{attribute}_height", image["height"]) unless self.send("#{attribute}_height") ==  image["height"]
      #If the path isn't right, update it
        if self.send("#{attribute}_path") != stored_path
          self.update_attribute("#{attribute}_path", stored_path)
        end
    end
end
