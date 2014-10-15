class Post < ActiveRecord::Base
  attr_accessible :category, :content, :recipient, :recipient_id, :timestampe, :user_id, :visibility

  def self.llimage(image, topicid)
    uploadpath = "http://u.endoftheinter.net/u.php?topic=" + topicid
    if image.rating == "NWS"
      "NWS! Sorry"
    else
      if image.llimagelink.nil? || image.llimagelink.empty?
        @path = Rails.root.join('public', 'images', image.path).to_s
        if File.exist?(@path)
          buffer = StringIO.new(File.open(@path,"rb") { |f| f.read})
          miniimage = MiniMagick::Image.read(buffer)
          if miniimage["height"] > 550 || miniimage["width"] > 600
            miniimage.resize "600x550"          
            resizedpath = Rails.root.join('public', 'images', image.path).to_s + " resized"
            miniimage.write(resizedpath)
            @path = resizedpath
          end
        end
        size = File.size(@path)
        if size < 2080000
          agent = Mechanize.new
          agent.cookie_jar.load 'llcookies'
          agent.get(uploadpath)
          
          if agent.page.form.nil? == true
            agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
            agent.get(uploadpath)
            agent.page.form.b = "Hibiki"
            agent.page.form.p = "ironkitten59"
            agent.page.form.submit
          end
          
          page = agent.page
          page.form.file_uploads.first.file_name = @path
          page.form.submit
          
          doc = agent.page.parser
          @imagelink = "" #clears out imagelink so you don't use it twice accidentally
          @imagelink = doc.xpath("//div[@class='img']/input").first.attributes["value"].value
          image.llimagelink = @imagelink
          image.save
          image.llimagelink
        else
          "This cover was too big to upload to LL"
        end
      else
        image.llimagelink
      end #Ends if there is already an imagelink
    end #Ends NWS
  end 
  
  def self.cut_message(messagearry, message)
    #If the message is longer than 9000 characters, we cut it and add it to the array
    if message.length > 9000
      message = message + "\n Continued next post\n"
      messagearray << message
      message = ""
    end
  end
  
  def self.add_album_info(album, topicid)
    #This will add one album to the message
    if album.nil? == false && album.class == Album
      #Check if the album is a limited edition. if it is, don't do anything.
      if RelatedAlbums.where(:category => "Limited Edition", :album1_id => album.id).empty?
        #Create a blank messagepart
        messagepart = ''
        #Add the name
        messagepart = messagepart + "\n<b><u>" + album.name + "</u></b>\n" #start with an empty messagepart
        #Add a cover
        if album.primary_images.first.nil? == false
          messagepart = messagepart + "<pre>     </pre><spoiler caption=\"Cover\">" + Post.llimage(album.primary_images.first, topicid) + "</spoiler>\n"
        else
          messagepart = messagepart + "<pre>     </pre>No cover available\n"
        end
        #Catalog Number
        messagepart = messagepart + "<pre>     </pre>Catalog Number: " + album.catalognumber + "\n"
        #Release Date
        messagepart = messagepart + "<pre>     </pre>Release Date: " + album.releasedate.strftime("%B %d, %Y") + "\n"  
        # #Tracklist
        # if album.songs.empty? == false
          # messagepart = messagepart + "<pre>     </pre><spoiler caption=\"Tracklist\">\n"
          # album.songs.each do |song|
            # messagepart = messagepart + "<pre>         </pre>" + song.tracknumber + " " + song.name + "\n"
          # end
          # messagepart = messagepart + "</spoiler>\n \n"                  
        # end
        
        #Add the messagepart to the message
        messagepart
      else
        ''    
      end
    else
      ''
    end
  end
end
