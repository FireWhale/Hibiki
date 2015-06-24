module FixModule
  #This module contains a bunch of processes that performed a one-time fix on the database
  #This used to be stored in albums_controller
  
  def conversion #This was code to convert artist_albums into bitmask form.
    @relationship = %w[Composer Arranger Performer Lyricist]  
    @albums=Album.includes(:artist_albums).all
    @albums.each do |album|
      @album = album
      @artistids = @album.artist_albums.map(&:artist_id).uniq
      @artistids.each do |artistid|
        @artistalbums = @album.artist_albums.where(:artist_id => artistid)
        @categories = []
        @artistalbums.each do |each|
          @categories << each.category
        end
        @bitmask= (@categories & @relationship).map { |r| 2**@relationship.index(r) }.sum
        @artistalbums.each do |exists|
          exists.delete
        end
        @album.artist_albums.create(:artist_id => artistid, :category => @bitmask)
      end
    end
  end 
  
  def folderrename #this was code to change the naming format of the album art direcotires   
    @albums.each do |album|      
      @path = album.name + " - " + album.catalognumber + " - " + album.id.to_s
      # @path = @album.name + " - " + @album.catalognumber + " - " + @album.id.to_s
      @path= @path.gsub(/[\\?\/|*:#.<>%"]/, "") 
      @directory_name='app/assets/images/albumart/'+ @path    
      if File.exists?(@directory_name)
        @newpath = album.catalognumber + " - " + album.id.to_s
        @newpath = @album.catalognumber + " - " + @album.id.to_s
        # @newpath= @newpath.gsub(/[\\?\/|*:#.<>%"]/, "")
        @newdirectoryname='app/assets/images/albumart/' + @newpath  
        FileUtils.mv(@directory_name, @newdirectoryname)
      end
    end
  end
  
  def albumsongpathrename #refer to the previous method. This one is meant to change the image paths. 
    
    @albums.each do |album|
      @images = album.images
      if @images.empty? == false
        @images.each do |image|
          @path = album.catalognumber + " - " + album.id.to_s
          @path = @path.gsub(/[\\?\/|*:#.<>%"]/, "") #stripping the name for proper directory creation
          image.path = "albumart/" + @path + "/" + image.name
          image.save
        end
      end
    end
    
  end
  
  def albumsourceconversion #This changes the album-source association from HABTM to Has many Through.
    Album.all.each do |album|
      album.oldsources.each do |source|
        AlbumSource.create!(:album_id => album.id, :source_id => source.id)
      end
    end
  end
  
  def updatealbumreferences #this fixes the 78 albums (post id 136) that accidentally had \r appended to them. 
    @albums.each do |each|
      each.update_attribute(:reference, {:vgmdb => each.reference[:vgmdb].chomp("\r") })
    end
  end
  
  def changecdjapanreferences #used to convert cdjapan links to account for cdjapan changing website design
    Album.where("reference like ?", "%cdjapan%").each do |album|
      cdjapanref = album.reference[:cdjapan]
      if cdjapanref.nil? == false and cdjapanref.include?("product") == false
        album.reference[:cdjapan] = "http://www.cdjapan.co.jp/product/" + cdjapanref.split("=").last
        album.save
      end 
    end
  end
  
  def fixreleasedates #Used to fix Release dates. 
    # This was run March 6th, 2014
    #Previously, all dates had day, month, and year. This caused inaccuracies when only year/month was given.
    #Since they defaulted to the first (or january), we will be looking at all albums with the first.
    #We will go into the vgmdb record, then grab the date again. We will then look at the length
    agent = Mechanize.new
    links = ''
    Album.where("strftime('%d', releasedate) = ?", "01").each do |each|
      if each.reference.nil? == false && each.reference[:vgmdb].nil? == false
        url = each.reference[:vgmdb]
        agent.get(url)
        doc = agent.page.parser
        rawreleasedate = doc.xpath("//table[@id='album_infobit_large']//tr[2]//td[2]").text
        begin 
          releasedate = Date.parse rawreleasedate
        rescue
          begin
            releasedate = Date.strptime(rawreleasedate, '%Y')        
          rescue
            rawreleasedate = doc.xpath("//table[@id='album_infobit_large']//tr[2]//td[2]/a[1]").text
            releasedate = Date.parse rawreleasedate
            links = links + url
          end
        end
        if rawreleasedate.strip.length == 4 #if there's only a year, set bitmask
          each.update_attributes(:releasedate_bitmask => 6)
        elsif rawreleasedate.strip.length == 8 #There's a month and a year
          each.update_attributes(:releasedate_bitmask => 4)
        else
          releasedate_bitmask = 0
        end
      end
    end
    #This was used to check the results: the list was opened with open urls.
    list = ""
    Album.where("strftime('%d', releasedate) = ?", "01").each do |each|
      if each.releasedate_bitmask.nil?
        if each.reference.nil? == false && each.reference[:vgmdb].nil? == false
          url = each.reference[:vgmdb]
          list = list + url + "\n"
        end
      end
    end
    print list
  end

  def albumreferencefix
    #This changes the reference hash key to the updated one.
    #This was done March 6th for: VGMDB: Albums, Artists, Sources, Organizations 
    #CDJapan: Albums
    Album.all.each do |each|
      if each.reference.nil? == false && each.reference[:vgmdb].nil? == false
        link = each.reference.delete(:vgmdb)
        each.reference[:VGMdb] = link
        each.save
      end
    end

    Source.all.each do |each|
      if each.reference.nil? == false && each.reference[:vgmdb].nil? == false
        link = each.reference.delete(:vgmdb)
        each.reference[:VGMdb] = link
        each.save
      end
    end
    
    Organization.all.each do |each|
      if each.reference.nil? == false && each.reference[:vgmdb].nil? == false
        link = each.reference.delete(:vgmdb)
        each.reference[:VGMdb] = link
        each.save
      end
    end    
    
    Artist.all.each do |each|
      if each.reference.nil? == false && each.reference[:vgmdb].nil? == false
        link = each.reference.delete(:vgmdb)
        each.reference[:VGMdb] = link
        each.save
      end
    end
    
    Album.all.each do |each|
      if each.reference.nil? == false && each.reference[:cdjapan].nil? == false
        link = each.reference.delete(:cdjapan)
        each.reference[:CDJapan] = link
        each.save
      end      
    end
  end
  
  def thumbnail_generator #This creates thumbnails out of all existing images
    #93307 images were affected by this
    #Run March 8th, 2014. Finished March 10th haha.
    #WARNING: This required a model definition found in images_module.rb
    #Please def create_image_thumbnails first
    #This was done in batches of 2500. 
    images = Image.where(:id => 92500..95000)
    images.each do |image|
      create_image_thumbnails(image)
    end
  end

  def fixthumbnail_generator #I made #30345 image records have the wrong field
    #I need to remove "public/images/" from the paths of thumbs and mediums
    images.each do |image|
      if image.medium_path.nil? == false && image.medium_path.empty? == false
        path = image.medium_path
        if path.include?("public/images")
          image.medium_path = path.split("public/images/")[1]
          image.save
        end
      end
      if image.thumb_path.nil? == false && image.thumb_path.empty? == false
        path = image.thumb_path
        if path.include?("public/images")
          image.thumb_path = path.split("public/images/")[1]
          image.save
        end
      end
    end
  end
  
  def upscale_identifier
    #So I accidnetally had the criteria - 
    #if height> 500 or width > 750, resize to
    #max height 750 or max width 500
    #That means (Yes I spent 20 mins figuring this out) that I upscaled images with the criteria:
    #height is between 500 and 750 and width <500
    #Also, this means I sometimes only scaled down to 750 (and original width <500), but that's downscale anyhow
    imagelist = []
    Image.all(:conditions => "primary_flag <> ''").each do |image|
      if image.primary_flag.nil? == false && image.primary_flag.empty? == false
        if image.medium_path.nil? == false && image.medium_path.empty? == false
          imagelist << image          
        end
      end
    end
    list = []
    imagelist[10000..12500].each do |image|
      root_path = Rails.root.join('public', 'images', image.path).to_s
      if File.exist?(root_path)
        buffer = StringIO.new(File.open(root_path,"rb") { |f| f.read})
        miniimage = MiniMagick::Image.read(buffer)     
        if miniimage["height"] > 500 && miniimage["height"] < 750 && miniimage["width"] <500
          list << image.id
        end
      end          
    end
    
    #output
    imageids = [582, 610, 1434, 1537, 2048, 2076, 2088, 2575, 3031, 3325, 3326, 4303, 5000, 5525, 5550, 5551, 5972, 6096, 6137, 6774, 6935, 6978, 7088, 7438, 7688, 8439, 8509, 8578, 9366, 9742, 9751, 9832, 9834, 9851, 9865, 10704, 10711, 10721, 10790, 10810, 10886, 10959, 11464, 12560, 12574, 13264, 14296, 14857, 15037, 15696, 15818, 16736, 16739, 17155, 17461, 17491, 18125, 18648, 18889, 19000, 20135, 20940, 20994, 22559]
    imageids = imageids + [22860, 23419, 24254, 24462, 24468, 24523, 24524, 24563, 24660, 25028, 25032, 25044, 25250, 25277, 25703, 25742, 26184, 26309, 26623, 26846, 26866, 27010, 27069, 27514, 27585, 27734, 28876, 29891, 30977, 30978, 31273, 31443, 31937, 32115, 32244, 32673, 32677, 33018, 34753, 36064, 36902, 37123, 37186, 39207, 40218, 42622, 42860, 43268, 45448]
    imageids = imageids + [47159, 47722, 48465, 48513, 48822, 49996, 50349, 50372, 50640, 50651, 50904, 51198, 51282, 51286, 51324, 51376, 51377, 51390, 51766, 51975, 52068, 52077, 52201, 52213, 52335, 52487, 52514, 52624, 52629, 52655, 53116, 53277, 53640, 53799, 54042, 54044, 54207, 55486, 55541, 55585, 55691, 55743, 56025, 56026, 56468, 56810, 56866, 56887, 57028, 57119, 57362, 57455, 57854, 57903, 58674, 58863, 59041, 59863]
    imageids = imageids + [61442, 61938, 62172, 62240, 62473, 62793, 63477, 63691, 63709, 64387, 64548, 64879, 66543, 66877, 67419, 67430, 67808, 68760, 68805, 68908, 69196, 69414, 69472, 69620, 69952, 69955, 69958, 69961, 70406, 70425, 70476, 70497, 70883, 71225, 71645, 71731, 71736, 71740, 71742, 71757, 71762, 72758, 72804, 73002, 73004, 73082, 73581, 73585, 73587, 73722, 73925, 74057, 74134, 74625, 74626, 74832, 75138, 75448, 75484, 75514, 75662, 75677, 76226, 76495, 76707]
    imageids = imageids + [77091, 77160, 77214, 78272, 78292, 78645, 78832, 79377, 79455, 79593, 80430, 80881, 81265, 82554, 83382, 83401, 83435, 83684, 83934, 84142, 84277, 84645, 85002, 85138, 86245, 86395, 87054, 87133, 87135, 88593, 88674, 88679, 89328, 89475, 89492, 89984, 90058, 90197, 90544, 90576, 90601, 90642, 90645, 91286, 91427, 91578, 91831, 92653, 92682, 92684]   
  
    #Okay, so we look at each image. delete the medium folder, then run it through the process again.
    images = Image.find(imageids)
    
    images.each do |image|
      filename = image.medium_path.split("/")
      filename.pop
      folder = filename.join("/")
      folderpath = 'public/images/' + folder
      if File.exists?(folderpath)
        FileUtils.remove_dir(Rails.root.join(folderpath), true)
      end
      image.medium_path = ""
      image.save
      create_image_thumbnails(image)
    end
  end
  
  def album_namehash_fix
    #So the first 5050 or so albums don't have namehases! Judging from album 5054, 
    #it seems that I implemented namehashes after that. 
    #Performed march 22nd
    albums = Album.first(5053)
    albums.each do |album|
      if album.namehash.nil?
        hash = {:Romaji => album.name, :Japanese => album.altname}
        hash.delete_if { |k, v| v.nil? }
        album.namehash = hash
        album.save
      end
    end
  end
  
  def imagefix2
    #Performed 5/26/2014
    #So I found out that when I scrape, my code sets the primary flag of covers
    #AFTER I run the image thumbnail creation method
    #I fixed it, but now I have to find all the covers that don't have medium fields
    #Find all covers where medium_path is nil or empty
      covers1 = Image.where("primary_flag <> '' AND medium_path = ''")
      covers2 = Image.where("primary_flag <> '' AND medium_path IS NULL")
      covers = covers1 + covers2
    #Go through each image and set medium paths
      covers.each do |image|
        create_image_thumbnails(image)
      end
  end
  
  def albumevents
    #Turns out I didn't include dependent: :destroy on my album model's albumevent link
    #Now I have to find all the broken pointers
    brokenlinks = []
    Event.all.each do |event|
      event.album_events.each do |relation|
        if relation.album.nil?
          brokenlinks << relation
        end
      end
    end
  end
  
  def tag_rescrape_fix
    #Performed 8/29/2014
    #Turns out my Rescrape function broke when the tag was already present on the 
    #album. It did not properly check and it tried to add it again, throwing an error
    #This fix method will need to identify the albums that were mistakenly
    #assumed to be rescrape when they were not, because of the error.
    #First, we need to identify how many total rescrapes we have:
    Album.where(:classification => "CLEARED TO TAGS").count
    # => 624
    #Okay we have 624 of these, we need to parse them down a bit. 
    #Okay better idea: Parse the rescrape post to find history.
      #Found the date where the rescrape class->tags took effect:
      #Get number of albums after 8/10
      # => 185
    #Get albums that are new and were updated >20 seconds later than created
    @albums = Album.where(:classification => "CLEARED TO TAGS")
    list = []
    @albums.each do |album|
      if album.updated_at - album.created_at > 10
        list << album.id.to_s
      end
    end
    list.count # => 351
    #Combinining the two, we get:
    newlist = ["27891", "19573", "28449", "28555", "60", "21093", "28004", "27608", "28437", "27825", "28549", "30450", "30437", "24797", "15599", "14166", "14190", "14242", "14285", "14245", 
              "87", "231", "234", "30311", "30312", "25941", "8324", "28644", "28674", "28676", "28416", "28207", "28407", "28408", "28398", "28351", "28393", "28352", "28317", "28319", "28318", "28287", "28288", 
              "28293", "28291", "28251", "28279", "28280", "28254", "28209", "28219", "28230", "28228", "27870", "27974", "27759", "27666", "11517", "27461", "27545", "27568", "27453", "27410", "27396",
              "27374", "27365", "27301", "27295", "28561", "28560", "27294", "27213", "27253", "27291", "27211", "27207", "27197", "27204", "27082", "27181", "27195", "27536", "27166", "26284", "26283", 
              "27081", "27078", "27076", "26649", "26279", "26047", "3507", "5775", "5786", "757", "5687", "14980", "1932", "27421", "26045", "25652", "25593", "25599", "25646", "25469", "25466", "25438",
              "22841", "24411", "25098", "24895", "25234", "23279", "25196", "24062", "24085", "24221", "24275", "23460", "23487", "23501", "23752", "23748", "23586", "23757", "23881", "23375", "23348", 
              "23247", "23387", "23406", "23420", "23453", "23438", "23432", "23023", "22984", "22985", "23209", "22880", "23210", "22696", "22781", "23203", "22157", "22023", "21855", "21481", "21586", 
              "21836", "21782", "28535", "28534", "5649", "5648", "25862", "26232", "12139", "3574", "20744", "4694", "1917", "18324", "4695", "15001", "16556", "14415", "14164", "15620", "13417", "16568",
              "16919", "16621", "16548", "15746", "15682", "15125", "20934", "4699", "3731", "3730", "112", "132", "135", "141", "243", "1184", "5717", "5718", "5781", "15274", "16730", "21582", "21637",
              "21756", "21763", "21779", "21781", "21859", "21882", "21899", "21949", "22017", "22022", "22024", "22049", "22111", "22341", "22349", "22408", "22410", "22523", "22539", "22589", "23788", 
              "24023", "24177", "24247", "24325", "24355", "24449", "24865", "25070", "25195", "25291", "25647", "26348", "27080", "27083", "27087", "27165", "27167", "27168", "27169", "27182", "27201", 
              "27203", "27400", "27446", "27463", "27464", "27465", "27470", "27546", "27609", "27613", "27620", "27622", "27633", "27684", "27775", "27799", "27800", "28097", "28176", "28210", "28212", "28217", 
              "28229", "28245", "28249", "28253", "28255", "28292", "28296", "28304", "28306", "28307", "28313", "28320", "28326", "28332", "28333", "28337", "28339", "28345", "28349", "28353", "28374", "28375", 
              "28376", "28395", "28396", "28405", "28406", "28409", "28414", "28447", "28448", "28553", "28554", "28562", "30449", "31732", "31739", "31753", "31760", "31762", "31764", "31766", "31772", "31775", 
              "31777", "31779", "31780", "31781", "31790", "31808", "31812", "31816", "31825", "31828", "31830", "31843", "31844", "31845", "31856", "31867", "31907", "31909", "31910", "31914", "31915", "31920", 
              "31930", "31934", "31935", "31946", "31955", "31961", "31962", "31964", "31972", "31981", "31991", "31994", "31999", "32001", "32004", "32008", "32024", "32025", "32030", "32032", "32033", "32035", 
              "32037", "32062", "32080", "32085", "32090", "32093", "32101", "32107", "32126", "32128"]
    #Okay I'm just going through firefox history and finding all the pages I've visited 3 times
    #Working through them manually
    #Finished 8/30. about 180 albums looked at
  end
  
  def add_status_to_songs
    #Performed 11/26/2014
    #Recent Validation additions have made all of our current songs invalid, since they have no status. We're just gonna add Unreleased to all of them.
    Song.where(status: nil).update_all(status: "Unreleased")
    #easy peasy
  end
  
  def change_wishlist_to_wishlisted
    #Performed 3/5/2015
    Collection.where(relationship: 'Wishlist').update_all(relationship: 'Wishlisted')
  end
  
  def migrate_references_to_reference_model
    #Performed 6/21. 
    #Moving from the hashed column to the actual model. 
    @album_count, @artist_count, @organization_count, @source_count, @song_count, @event_count = 0, 0, 0, 0, 0, 0
    Album.includes(:translations).all.each do |album|
      @album_count += album.reference.count unless album.reference.nil?
    end
    #36544 count
  
    Album.all.each do |album|
      unless album.reference.nil?
        album.reference.each do |k,v|
          album.references.create(:site_name => k.to_s, :url => v)
        end
      end
    end
    
    Reference.count #Now we check to make sure all the references were moved to Reference model
    # => 36544
    
    Artist.includes(:translations).all.each do |artist|
      @artist_count += artist.reference.count unless artist.reference.nil?
    end
    #268
    
    Artist.all.each do |artist|
      unless artist.reference.nil?
        artist.reference.each do |k,v|
          artist.references.create(:site_name => k.to_s, :url => v)
        end
      end
    end
    
    Reference.count
    # => 36812 <--- matches up!
    
    Organization.includes(:translations).all.each do |org|
      @organization_count += org.reference.count unless org.reference.nil?
    end
    # => 39
    
    Organization.all.each do |org|
      unless org.reference.nil?
        org.reference.each do |k,v|
          org.references.create(:site_name => k.to_s, :url => v)
        end
      end
    end
    
    Reference.count
    # => 36851 <--- matches up!
    
    #Songs do not have any references yet! :<
    
    Source.includes(:translations).all.each do |source|
      @source_count += source.reference.count unless source.reference.nil?
    end
    #source count = 331
    
    
    Source.includes(:translations).all.each do |source|
      unless source.reference.nil?
        source.reference.each do |k,v|
          source.references.create(:site_name => k.to_s, :url => v)
        end
      end
    end
    
    Reference.count
    # => 37182 <--- matches up!
    
    Event.includes(:translations).all.each do |event|
      @event_count += event.reference.count unless event.reference.nil?
    end
    #313
    
    
    Event.all.each do |event|
      unless event.reference.nil?
        event.reference.each do |k,v|
          event.references.create(:site_name => k.to_s, :url => v)
        end
      end
    end
    
    Reference.count
    # => 37495 <--- matches up!
    
    
  end
  
  
  
end
