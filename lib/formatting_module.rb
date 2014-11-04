module FormattingModule
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def full_update(keys,values)
      #Push em into arrays if it's just one
      keys = [keys] if keys.class != Array
      values = [values] if values.class != Array
      #Zip them up and then loop
      keys.zip(values).each do |info|
        record = self.find_by_id(info[0])
        record.full_update_attributes(info[1]) unless record.nil?
      end
    end
    
    def full_create(keys,values)
      #Push em into arrays if it's just one
      keys = [keys] if keys.class != Array
      values = [values] if values.class != Array
      keys.zip(values).each do |info|
        record = self.new
        record.full_save(info[1])     
      end      
    end
  end
  
  def full_save(values)
    #This method will call the full_update_atributes method for whatever record it's called on.
    if self.save
      #If the required info is correct, the save will go through and we can call full_update
      self.full_update_attributes(values)
    end
  end

  def full_update_attributes(values)
    #The meat and potatoes of the whole operation. get the fields we have to address from a model constant
    fields = self.class::FullUpdateFields
    
    #Primary Relations by ID
      unless fields[:relations_by_id].nil?
        fields[:relations_by_id].each do |model, info|
          #Update Records
            update_records = values.delete info[2]
            self.update_primary_relation(update_records, info[4]) unless update_records.nil?
          #Destroy Records
            remove_records = values.delete info[3]
            self.delete_records(remove_records, info[4]) unless remove_records.nil?
          #New Records
            new_ids = values.delete info[0]
            new_categories = values.delete info[1]
            self.create_primary_relation(new_ids, new_categories, model.to_s, info[5]) unless new_ids.nil? || new_categories.nil?
        end
      end    
    #Self Relations
      unless fields[:self_relations].nil?
        #Update Records
          update_records = values.delete fields[:self_relations][2]
          self.update_related_model(update_records.keys, update_records.values) unless update_records.nil?
        #Destroy Records
          remove_records = values.delete fields[:self_relations][3]
          self.delete_records(remove_records, "Related#{self.class.to_s}s".constantize) unless remove_records.nil?
        #New Records
          new_ids = values.delete fields[:self_relations][0]
          new_categories = values.delete fields[:self_relations][1]
          self.create_self_relation(new_ids, new_categories) unless new_ids.nil? || new_categories.nil?
      end
    #Images
      images = values.delete :images
      unless fields[:images].nil? || images.nil?
        folder = self.id.to_s if fields[:images][0] == "id"
        folder = self.catalog_number + ' - ' + self.id.to_s if fields[:images][0] == "album" #albums have a different folder structure
        images.each {|image| self.upload_image(image, folder, fields[:images][1], fields[:images][2]) }
      end
    #Reference
      references = values.delete :reference
      self.format_references_hash(references) if fields[:reference] == true && references.nil? == false
    #Dates
      fields[:dates].each {|date| self.format_date_helper(date,values)} unless fields[:dates].nil?
    #Add Songs - Album only
      unless fields[:songs].nil?
        new_songs = values.delete :new_songs
        self.add_songs(new_songs) unless newsongs.nil?
      end
    #Add Sources - Album/Song require less/more complex methods 
      unless fields[:sources_for_album].nil?
        new_source_ids = values.delete :new_source_ids
        self.add_sources_for_albums(new_source_ids) unless new_source_ids.nil?
        remove_sources = values.delete :remove_sources
        remove_sources.each {|id| self.source.delete(Source.find_by_id(id))} unless remove_sources.nil?
      end
      unless fields[:sources_for_song].nil?
        #Update
          song_sources = values.delete :song_sources
          SongSource.update(song_sources.keys, song_sources.values) unless song_sources.nil? || song_sources.keys.empty?
        #Destroy
          remove_sources = values.delete :remove_sources
          remove_sources.each {|source_id| self.sources.delete(Source.find_by_id(source_id))} unless remove_sources.nil?
        #New
          new_sources = values.delete :new_sources
          self.add_sources_for_songs(new_sources) unless new_sources.nil?          
      end
    #Add Artists - Album/Song requires a more complex method
      unless fields[:artists_for_album].nil?
        update_artist_albums = values.delete fields[:artists_for_album][2]
        self.update_artists_for_albums(update_artist_albums) unless update_artist_albums.nil?
        new_artist_ids = values.delete fields[:artists_for_album][0]
        new_artist_categories = values.delete fields[:artists_for_album][1]
        self.add_artists_for_albums(new_artist_ids,nil,new_artist_categories) unless new_artist_ids.nil? || new_artist_categories.nil?
      end
      unless fields[:artists_for_song].nil?
        update_artist_songs = values.delete fields[:artists_for_song][2]
        self.update_artists_for_songs(update_artist_songs) unless update_artist_songs.nil?
        new_artiat_ids = values.delete fields[:artists_for_song][0]
        new_artist_categories = values.delete fields[:artists_for_song][0]
        self.add_artists_for_songs(new_artist_ids,new_artist_categories) unless new_artist_ids.nil? || new_artist_categories.nil?
      end
    #Scrapes - Album Only..just gonna write out the logic here
      unless fields[:scrapes].nil?
        #Organizations:
          new_organization_names = values.delete fields[:scrapes][:organization][0]
          new_organization_categories = values.delete fields[:scrapes][:organization][1]
          unless new_organization_names.nil? || new_organization_categories.nil?
            new_organization_names.zip(new_organization_categories).each do |info|
              unless info[0].empty? || info[1].empty?
                organization = Organization.find_by_name(info[0])
                organization = Organization.create(name: info[0], status: "Unreleased") if organization.nil?
                self.album_organizations.create(:organization_id => organization.id, :category => info[1])    
              end
            end
          end 
        #Sources
          new_source_names = values.delete fields[:scrapes][:sources][0]
          unless new_source_names.nil?
            new_source_names.reject {|c| c.empty? }.each do |name|
              source = Source.find_by_name(name)
              source = Source.create(name: name, status: "Unreleased") if source.nil?
              self.sources << source
            end
          end
        #Artists
          new_artist_names = values.delete fields[:scrapes][:artists][0]
          new_artist_categories = values.delete fields[:scrapes][:artists][1]
          self.add_artists_for_albums(nil,new_artist_names,new_artist_categories) unless new_artist_names.nil? || new_artist_categories.nil?
      end
    #Track Numbers/ Disc Numbers / Lengths - Song Only
      unless fields[:track_numbers].nil?
        duration = values.delete :duration #Format the duration into seconds if it includes ":"
        values[:length] = ( duration.include?(":") ? (duration.split(":")[0].to_i * 60 +  duration.split(":")[1].to_i ) : duration)
        track_number = values.delete :track_number
        if track_number.split(".")[1].length < 2 #Format the tracknumber into disc_number and track_number
          disc_number = track_number.split(".")[0] 
          track_number =  track_number.split(".")[1].rjust(2,'0')
          values[:disc_number] = disc_number
        end
        values[:track_number] = track_number
      end
    #Events/Season
      #Events - Albums only
        unless fields[:events].nil?
          new_events = values.delete :new_event_shorthands #Adding
          self.add_events(new_events) unless new_events.nil?
          remove_events = values.delete :remove_events  #Removing
          remove_events.each {|event_id| self.events.delete(Event.find_by_id(event_id))} unless remove_events.nil?
        end
      #Seasons - Sources only
        unless fields[:seasons].nil?
          new_seasons = values.delete :new_season_names #Adding
          self.add_seasons(new_seasons) unless new_seasons.nil?
          remove_seasons = values.delete :remove_seasons #Removing
          remove_seasons.each {|season_id| self.seasons.delete(Season.find_by_id(season_id))} unless remove_seasons.nil?
        end
    #Finally, update with attr_accessible values
      self.update_attributes(values)
  end

#-----------------------------------------#
#These are the methods used in full update!
#-----------------------------------------#

  def format_references_hash(ref_hash)
    references = ref_hash[:types].zip(ref_hash[:links]) #Zip up the types and links
    self.reference = {} #Clear the old references
    types = Album::ReferenceLinks.map(&:last).map(&:to_s) #Get a list of valid types
    references.each do |reference|
      #make sure they aren't empty and included in ReferenceLinks
      if reference[0].empty? == false && reference[1].empty? == false && types.include?(reference[0])
        new_link = {reference[0].to_sym => reference[1]}
        self.reference = self.reference.merge(new_link)
      end
    end
  end

  def format_date_helper(field,values)  
    #Allows partial dates in the following fields:
    #Grab the date from values
    year = values[field + '(1i)']
    month = values[field + '(2i)']
    day = values[field + '(3i)']
    #search for related bitmask field. if it doesn't exist, return date
    if self.respond_to?(field + "_bitmask") && year.nil? == false && month.nil? == false && day.nil? == false
      unless year.empty? && month.empty? && day.empty?
        #If they are all empty, do nothing.
        bitmask = 0
        year, bitmask = '1900', bitmask + 1 if year.empty?
        month, bitmask = '1', bitmask + 2 if month.empty?
        day, bitmask = '1', bitmask + 4 if day.empty?
        self.send(field + '_bitmask=', bitmask)  
        values[field + '(1i)'].replace year
        values[field + '(2i)'].replace month
        values[field + '(3i)'].replace day     
      end
    end 
  end

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
    self.images.empty? ? priflag = flag : priflag = '' 
    #Finally, create an image record and add the image to the instance.
    if image_name.empty? == false && image.path.empty? == false
      @image = Image.new(name: image_name, path: image_path, primary_flag: flag)
      self.images << @image
    end
  end
  
  def create_self_relation(ids,categories)
    #This method is used to create a relation between two records of the same model.
    #This method is used for Albums, Artists, Organizations, Sources, and Songs.
    model = self.class.to_s.downcase
    ids.zip(categories).each do |each|
      if each[0].empty? == false
        exists = self.class.find_by_id(each[0])
        if exists.nil? == false
          if each[1].starts_with?("-")
            category = each[1].slice(1..-1)
            self.send("related_#{model}_relations2").create(("#{model}1_id").to_sym => exists.id, :category => category)
          else
            self.send("related_#{model}_relations1").create(("#{model}2_id").to_sym => exists.id, :category => each[1])          
          end
        end
      end
    end  
  end

  def create_primary_relation(ids, categories, model, relationship)
    ids.zip(categories).each do |new_relation|
      unless new_relation[0].empty? || new_relation[1].empty?
        record = model.capitalize.constantize.find_by_id(new_relation[0])
        self.send(relationship).create("#{model}_id".to_sym => record.id, "#{self.class.to_s.downcase}_id".to_sym => self.id, category: new_relation[1]) unless record.nil?
      end
    end
  end

  def update_related_model(keys,values)
    #this can only update self relations of the class of the record it was called on.
    #I'm really just too lazy to learn how to make this a class method instead of an instance method.
    model = self.class.to_s.downcase
    keys = [keys] if keys.class != Array
    values = [values] if values.class != Array
    keys.zip(values).each do |relation|
      if relation[1]['category'].starts_with?("-")
        relatedmodel = ("Related" + model.capitalize + "s").constantize.find_by_id(relation[0])
        relation[1][model + '1_id'] = relatedmodel.send(model + "2_id")
        relation[1][model + '2_id'] = relatedmodel.send(model + "1_id")
        relation[1]['category'] = relation[1]['category'].slice(1..-1) #takes off the "-" 
      end
      ("Related" + model.capitalize + "s").constantize.update(relation[0], relation[1])
    end
  end
  
  def update_primary_relation(records, model) 
    records.each { |k,v| model.find_by_id(k).update_attributes(v) unless v['category'].empty? }
  end
  
  def delete_records(ids, model)
    ids.each { |id| model.find_by_id(id).destroy unless id.to_s.empty?}
  end

  def add_events(events)
    events.each do |shorthand|
      event = Event.find_by_shorthand(shorthand) 
      event = Event.create(shorthand: each) if event.nil? #create a new event if not present
      self.events << event
    end
  end
  
  def add_seasons(seasons)
    seasons.each do |name|
      season = Season.find_by_name(name)
      self.seasons << season unless season.nil? #don't create a new season if not present
    end
  end  

  def add_songs(songs)
    unless newsongs['tracknumbers'].nil? || newsongs['names'].nil?
      #Fill in the values that are not required
        newsongs['namehashes'] = Array.new(newsongs['names'].count, {}) if newsongs['namehashes'].nil?
        newsongs['lengths'] = Array.new(newsongs['names'].count, 0) if newsongs['lengths'].nil?
      #Zip them up and add them to the album
        newsongs['tracknumbers'].zip(newsongs['names'], newsongs['lengths'], newsongs['namehashes']). each do |info|
          self.songs.create(track_number: info[0], name: info[1], length: info[2], namehash: info[3], status: "Unreleased")
        end
    end
  end
  
  def add_sources_for_albums(source_ids) #for albums
    source_ids.reject {|c| c.empty?}.each do |source_id|
      source = Source.find_by_id(source_id)
      self.sources << source unless source.nil?
    end
  end
  
  def add_sources_for_songs(sources)
    unless sources[:ids].nil? #check the hash to make sure there are IDs
      sources[:ids].zip(sources[:classification],sources[:op_ed_number],sources[:ep_numbers]).each do |info|
        source = Source.find_by_id(info[0])
        unless source.nil?
          self.song_sources.create(:source_id => info[0], :classification => info[1], :op_ed_number => info[2], :ep_numbers => info[3])
          #Check to see if source is in info and add it if it isn't
          album_source = AlbumSource.where(:source_id => source.id, :album_id => self.album.id)
          self.album.album_sources.create(:source_id => source.id) if album_source.empty?
        end
      end      
    end
  end
  
  def add_artists_for_albums(ids, names, categories)
    unless categories.nil?
      #Prepare categories
      categories.pop
      categories = categories.split { |i| i == "New Artist"}
      unless names.nil? #If names are passed in, it'll fall to here
        replace_artists = Album::Artistreplace
        names.zip(categories).each do |info|
          unless info[0].empty? || info[1].empty?
            bitmask = Artist.get_bitmask(info[1])
            if replace_artists.map {|n| n[0]}.include?(info[0]) #if found in replace artists, replace the artist
              artist = Artist.find_by_id(replace_artists[replace_artists.index {|n| n[0] == info[0] }][1])
            else
              artist = Artist.find_by_name(info[0])
              artist = Artist.create(name: info[0], status: "Unreleased") if artist.nil?
            end
            self.artist_albums.create(:artist_id => artist.id, :category => bitmask)   
          end
        end
      end
      unless ids.nil? #If ids are passed in, it'll fall to here
        ids.zip(categories).each do |info|
          unless info[0].empty? || info[1].empty?
            bitmask = Artist.get_bitmask(info[1])
            artist = Artist.find_by_id(info[0])
            self.artist_albums.create(:artist_id => artist.id, :category => bitmask) unless artist.nil?          
          end
        end
      end
    end
  end
  
  def update_artists_for_albums(artist_albums)
    artist_albums.each do |k,v|
      artist_album = ArtistAlbum.find_by_id(k)
      unless artist_album.nil?
        bitmark = Artist.get_bitmask(v)
        bitmask == 0 ? artist_album.destroy : ArtistAlbum.update(artist_album.id, category: bitmask)
      end
    end
  end
  
  def update_artists_for_songs(artist_songs)
    artist_songs.each do |k,v|
      artist_song = ArtistSong.find_by_id(k)
      unless artist_song.nil?
        bitmask = Artist.get_bitmask(v)
        if bitmask == 0
          artist_song.destroy
        else
          ArtistSong.update(artist_song.id, category: bitmask)
          #Update artist_albums as well
          unless self.album.nil?
            album_artist = ArtistAlbum.where(artist_id: artist_song.artist.id, album_id: self.album.id)
            if album_artist.empty? #If can't find one, create it
              self.album.artist_albums.create(artist_id: artist_song.artist.id, category: bitmask)
            else
              #Grab the categories, merge them, get uniques. 
              album_artist = album_artist.first
              categories = Artist.get_categories(album_artist.category)
              uniquecategories = (v + categories).uniq
              albumbitmask = Artist.get_bitmask(uniquecategories)
              album_artist.update_attributes(category: albumbitmask)
            end
          end
        end
      end
    end
  end
  
  def add_artists_for_songs(ids, categories)
    categories.pop
    categories = categories.split { |i| i == "New Artist"}
    ids.zip(categories).each do |info|
      unless info[0].empty? || info[1].empty?
        bitmask = Artist.get_bitmask(info[1])
        artist = Artist.find_by_id(info[0])
        unless artist.nil?
          #Create the artist-song association
          self.artist_songs.create(:artist_id => artist.id, :category => bitmask)
          #update AlbumArtist as well
          unless self.album.nil?
            album_artist = ArtistAlbum.where(:artist_id => artist.id, :album_id => self.album.id)
            if album_artist.empty? #If can't find one, create it
              self.album.artist_albums.create(:artist_id => artist.id, :category => bitmask)
            else
              #Grab the categories, merge them, get uniques, add to album.
              album_artist = album_artist.first
              categories = Artist.get_categories(album_artist.category)
              uniquecategories = (newartistsong[1] + categories).uniq
              albumbitmask = Artist.get_bitmask(uniquecategories)
              album_artist.update_attributes(:category => albumbitmask)
            end
          end
        end
      end
    end
  end
  
end
