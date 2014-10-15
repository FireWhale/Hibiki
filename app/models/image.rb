class Image < ActiveRecord::Base
  attr_accessible :name, :path, :rating, :llimagelink, :primary_flag, :thumb_path, :medium_path

  # #Validation
  # validates :name, :presence => true
  
  
  #Modules
    include ImagesModule 
  
  #Callbacks
    before_destroy :delete_images
    
  
  #associations
    has_many :imagelists
    has_many :albums, :through => :imagelists, :source => :model, :source_type => 'Album'
    has_many :artists, :through => :imagelists, :source => :model, :source_type => 'Artist'
    has_many :organizations, :through => :imagelists, :source => :model, :source_type => 'Organization'
    has_many :sources, :through => :imagelists, :source => :model, :source_type => 'Source'
    has_many :users, :through => :imagelists, :source => :model, :source_type => 'User'

    def model
      (albums + artists + organizations + sources + users).first
    end
  #Gem Stuff
    #Pagination
    paginates_per 50
    
  def delete_images
    #deletes images from the hard drive.
    path = self.path
    mpath = self.medium_path
    tpath = self.thumb_path
    #if a path isn't empty, see if the file exists and delete it.
    if path.nil? == false && path.empty? == false
      full_path = "public/images/" + path
      if File.exists?(full_path)
        FileUtils.remove_file(Rails.root.join(full_path), true)
      end      
    end
    if mpath.nil? == false && mpath.empty? == false
      full_path = "public/images/" + mpath
      if File.exists?(full_path)
        FileUtils.remove_file(Rails.root.join(full_path), true)
      end       
    end
    if tpath.nil? == false && tpath.empty? == false
      full_path = "public/images/" + tpath
      if File.exists?(full_path)
        FileUtils.remove_file(Rails.root.join(full_path), true)
      end     
    end    
  end
  
  def full_update_attributes(values)
    #This checks the image size and makes sure the proper thumbnails are created
    if self.update_attributes(values)
      create_image_thumbnails(self)
    end
  end
  
end
