module ImagesModule

  def upload_image(image,path,directory,flag)
    #First, create the folder for the image
    path = path.gsub(/[\\?\/|*:#.<>%"]/, "") #stripping the name for proper directory creation
    full_path ='public/images/' + directory + path    
    Dir.mkdir(full_path) unless File.exists?(full_path)
    #Next, write the image to the disk in the folder created.
    image_name = image.original_filename
    image_path = directory + path + "/" + image_name
    File.open(Rails.root.join(full_path, image_name), 'wb') do  |file|
      file.write(image.read)
    end
    #Finally, create an image record and add the image to the instance.
    if image_name.empty? == false && image.path.empty? == false
      @image = Image.new(:name => image_name, :path => image_path, :primary_flag => flag)
      self.images << @image
      if @image.save
        create_image_thumbnails(@image)
      end
    end
  end
    
  def create_image_thumbnails(imagerecord)
    #this will create copies of an image for use if 
    root_path = Rails.root.join('public', 'images', imagerecord.path).to_s
    if File.exist?(root_path)
      buffer = StringIO.new(File.open(root_path,"rb") { |f| f.read})
      miniimage = MiniMagick::Image.read(buffer)     
      #If image is bigger than 500x500, we need to makea smaller pictures!
      if miniimage["width"] > 500 || miniimage["height"] > 500 
        #Only make medium sized for primary flagged records (covers and primaries)
        if imagerecord.primary_flag.nil? == false && imagerecord.primary_flag.empty? == false
          full_path = ('public/images/' + imagerecord.path).split("/")
          filename = full_path.pop
          newpath = full_path.join("/") + "/m"
          Dir.mkdir(newpath) unless File.exists?(newpath)
          miniimage.resize "500x500"
          new_full_path = Rails.root.join(newpath,filename)
          if File.exists?(new_full_path) == false
            miniimage.write(new_full_path)
          end
          imagerecord.medium_path = newpath.split("public/images/")[1] + "/" + filename
          imagerecord.save
        else
          imagerecord.medium_path = ""
          imagerecord.save
        end
      end
        #Make thumbs for everything greater than 250 (almost all), though.
      if miniimage["height"] > 225 || miniimage["width"] > 225
        full_path = ('public/images/' + imagerecord.path).split("/")
        filename = full_path.pop
        newpath = full_path.join("/") + "/t"
        Dir.mkdir(newpath) unless File.exists?(newpath)
        miniimage.resize "225x225"
        new_full_path = Rails.root.join(newpath,filename)
        if File.exists?(new_full_path) == false
          miniimage.write(new_full_path)
        end
        imagerecord.thumb_path = newpath.split("public/images/")[1] + "/" + filename  
        imagerecord.save
      else
        imagerecord.thumb_path = ""    
        imagerecord.save
      end
    end
  end  
    
  def destroy_images(path)
    #Delete associated image records
    self.images.destroy_all
    #Delete the directory
    full_path = 'public/images/' + path
    if File.exists?(full_path)
      FileUtils.remove_dir(Rails.root.join(full_path), true)
    end
  end
  
end
