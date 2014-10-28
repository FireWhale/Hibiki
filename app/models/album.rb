class Album < ActiveRecord::Base
  attr_accessible :altname, :catalog_number, :classification, 
                  :info, :name, :popularity, :private_info, :reference, 
                  :release_date, :status, :namehash, :image, :release_date_bitmask

  attr_accessible :newartistnames, :newartistcategories, :newsources, 
                  :neworganizationnames, :neworganizationcategories, :newsongs, 
                  :neweventshortnames, :newalbumids, :newalbumcategories

  serialize :reference
  serialize :namehash
  
  #Virtual Attributes
    attr_accessor :image, :newartistnames, :newartistcategories, :newsources, :neworganizationnames, :neworganizationcategories, :newsongs, :neweventshortnames, :newalbumids, :newalbumcategories
    #For seasons/wishlist
    attr_accessor :flag, :list_text

  include RelationsModule
  include ReferencesModule
  include ImagesModule 
  include FormattingModule

  #Callbacks
    before_destroy :delete_images
  
  #Multiple Model Constants - Put here for lack of a better place
    ReferenceLinks = [['vgmdb.net',:VGMdb], ['Last.FM',:lastpppfm], #seriously, going to sub ppp for a period
    ['Generasia Wiki',:generasia_wiki], ['Wikipedia.org',:wikipedia], 
    ['jpopsuki.eu',:jpopsuki], ['vndb.org',:visual_novel_database], 
    ['Anime News Network', :anime_news_network],
    ['Vocaloid wiki', :vocaloid_wiki],['Utaite wiki', :utaite_wiki],
    ['Touhou wiki', :touhou_wiki], ['Vocaloid db', :vocaloid_DB],
    ['Utaite db', :utaite_DB],
    ['Circus-co.jp',:circuspppco],['Comiket Website', :comiket],
    ['Official Website', :official],
    ['MyAnimeList', :myAnimeList],['IMDb', :iMDb],
    ['cdJapan', :CDJapan],
    ['Official Blog', :official_blog],
    ['Twitter', :twitter],
    ['Other', :other_reference ]]
    
    Status = ['Released', 'Unreleased', 'Hidden', 'Private']
      #Hidden - Just a placeholder in the database - maaya => maaya sakamoto
      #Private - Things that are out of scope of the database but I still like
      
    
    StatusDropdown = [['Released'], ['Unreleased'], ['Hidden'], ['Private'], ['IP - Incomplete Associations'], ['IP - Incomplete Songs'], ['IP - Incomplete Touhou Refs'], ['IP - Incomplete Song Refs']]

  #Model Constants    
    SelfRelationships = [['is a limited edition of', "Normal Versions", "Limited Editions", 'Limited Edition'],
    ['has the limited edition', '-Limited Edition'],
    ['is a reprint of', "Reprinted From", "Reprints", 'Reprint'],
    ['has the reprint', '-Reprint'],
    ['is an alternate printing of', "Alternate Printings", "Alternate Printings", 'Alternate Printing'], #Alternate printings = same songs
    ['has the alternate printing', '-Alternate Printing'],
    ['is in the same collection as', "Same Series", "Same Series", 'Collection'],
    ['is an alternate version of', "Alternate Printings", "Alternate Printings", 'Alternate Version'], #Alt versions = slightly different songs
    ['is an instrumental version of', "Normal Versions", "Instrumental Versions", 'Instrumental'],
    ['has the instrumental version', '-Instrumental']]
    
    #Tracklist options is a tricky variable
    #It needs to be stored in the user's preference as a bitmask, so add only to the end.
    #I have 2 fields within each value. 
    #Params options: What is sent in params <--key value (only one short enough xd)
    #Description: What is displayed to the user as a description of the option
    #In the controller, we'll match the params options to what it corresponds to in 
    #Hibiki's database and what it corresponds to in foobar
    TracklistOptions = {:disc_number => 'Disc numbers', :track_number => 'Track numbers',
      :title => 'Titles', :performers => 'Performers as artists (requires split artist)',
      :composers => 'Composers (requires split composers)',
      :performer_field => 'Performers as performers (requires split performer)',
      :album => "Album name", :sources => 'Source Material (requires split source)', 
      :year => 'Date (yyyy)', :full_date => 'Date (yyyy-mm-dd)', 
      :op => 'OP/ED/Insert Field', :genres => 'Genres', :catalog_number => 'Catalog Number',
      :events => 'Events (requires split event)', :arrangers => "Arrangers (requires split arrangers)"
      }
    #Artistreplace is used to replace names with IDs when adding artists by name to an album.
    #Since adding by name only applies to scrapes, we need a way to differeniate artists
    #with the same name. This will give a "default" ID to use, as well as keep track of
    #artists with the same name. 
    Artistreplace = [
      ['SHIHO', 39004 ], #2 artists. I've Sound SHIHO (39004) in favor of Stereopony SHIHO(3221)
      ['96', 39007 ], #2 artists. IOSYS guitarist (39007) in favor of guitarfreak's 96 (868))
      ['AKINO', 432 ], #2 artists. bless4 singer (432) in favor of 2nd Flush arranger (39017))
      ['Takashi', 4326 ], #3 artists. all pretty defunct. macado (3932), Birth Entertainment (4326), and touhouist (39019)
      ['void', 225 ], #IOSYS arranger (225) in favor of Divere Systems/Trance void (39102)
      ['Vivienne', 402 ], #Amateras singer (402) in favor of FELT singer (39103). Will probably need to check anyhow.
      ['Lily', 1901 ], #real life partner of morrigan (1901) in favor of vocaloid (41078)
      ['JIN', 1434 ], #Vocaloid producer over Musician and Beatmania Singer
      ['Peco', 5927] #Liz Triangle artist over some 1997 ost artist 
    ]
  
  #Validation
    validates :name, presence: true 
    validates :status, presence: true
    validates :catalog_number, presence: true, uniqueness: {scope: [:name, :release_date]}

  #associations
    #Primary Associations
      has_many :related_album_relations1, class_name: 'RelatedAlbums', foreign_key: 'album1_id', :dependent => :destroy
      has_many :related_album_relations2, class_name: 'RelatedAlbums', foreign_key: 'album2_id', :dependent => :destroy
      has_many :related_albums1, :through => :related_album_relations1, :source => :album2
      has_many :related_albums2, :through => :related_album_relations2, :source => :album1
     
      def related_album_relations
        related_album_relations1 + related_album_relations2
      end

      def related_albums
        related_albums1 + related_albums2
      end
              
      has_many :album_sources
      has_many :sources, :through => :album_sources, dependent: :destroy
      
      has_many :artist_albums
      has_many :artists, :through => :artist_albums, dependent: :destroy
      
      has_many :album_organizations
      has_many :organizations, :through => :album_organizations, dependent: :destroy

      has_many :songs, dependent: :destroy
      
    #Secondary Associations
      has_many :taglists, :as => :subject
      has_many :tags, :through => :taglists, dependent: :destroy
    
      has_many :imagelists, :as => :model
      has_many :images, :through => :imagelists, dependent: :destroy
      has_many :primary_images, :through => :imagelists, :source => :image, :conditions => "images.primary_flag = 'Cover'" 
      
      has_many :album_events
      has_many :events, :through => :album_events, dependent: :destroy
      
    #User Aassociations
      has_many :collections
      has_many :users, :through => :collections, dependent: :destroy
  
  #Gem Stuff
    #Pagination
    paginates_per 50
  
    #Sunspot Searching
    searchable do
      text :name, :catalog_number, :altname, :namehash 
      text :reference
      time :release_date
    end
    
  #Factory Methods
    def self.full_update(keys,values)
      #This will update all 5 models, images, and events.
      #First, address if there's only one key/value
        if keys.class != Array
          keys = [keys]
        end
        if values.class != Array
          values = [values]
        end      
        #Zip up the keys and values and iterate through them.
        albumupdates = keys.zip(values)
        albumupdates.each do |info|
          #Find the album
          album = Album.find_by_id(info[0])
          if album.nil? == false
            #If the album exists, push it over to the instance method full_update_attributes
            album.full_update_attributes(info[1])
          end
        end      
    end
    
    def full_update_attributes(values)
      #This method will update all 5 models, images, events, and format specific fields (release date)
      #First, format references
        references = values.delete :reference
        if references.nil? == false
          self.format_references_hash(references[:types],references[:links]) #From the Reference Module
        end
      #Artists
        #First, update any artistalbum records
        artistalbums = values.delete :artistalbums
        if artistalbums.nil? == false
          #The key is the ID fo the record, value is an array ["comp,etc."]
          artistalbums.each do |k,v|
            artistalbum = ArtistAlbum.find_by_id(k)
            if artistalbum.nil? == false
              bitmask = Artist.get_bitmask(v)
              if bitmask == 0
                artistalbum.destroy
              else
                ArtistAlbum.update(artistalbum.id, :category => bitmask)
              end
            end
          end
        end
        #Next, handle new artists. New artists are added to albums through scraping as well. 
        #Thus, we need to have separate methods to handle ID or names
        newartistnames = values.delete :newartistnames
        newartistids = values.delete :newartistids
        newartistcategories = values.delete :newartistcategories
        #For names: Split and then zip the categories into the names
        if newartistnames.nil? == false && newartistcategories.nil? == false
          newartistcategories.pop
          newartistcategories = newartistcategories.split { |i| i == "New Artist"}
          newartistalbums = newartistnames.zip(newartistcategories)    
          artistreplace = Album::Artistreplace
          newartistalbums.each do |artistalbum|
            if artistalbum[0].empty? == false && artistalbum[1].empty? == false
              bitmask = Artist.get_bitmask(artistalbum[1])
              if artistreplace.map{|n| n[0]}.include?(artistalbum[0]) 
                #This checks to see if this is in the special list of artists that need to
                #be replaced with IDs. E.G. SHIHO (2 different artists with same name)
                artist = Artist.find_by_id(artistreplace[artistreplace.index {|n| n[0] == artistalbum[0] }][1])
              else
                #Otherwise, just find the artist by name and continue like normal
                artist = Artist.find_by_name(artistalbum[0])
                if artist.nil?
                  artist = Artist.new(:name => artistalbum[0], :status => "Unreleased")
                  artist.save
                end                      
              end
              self.artist_albums.create(:artist_id => artist.id, :category => bitmask)   
            end
          end 
        end     
        #For IDs. Names and IDs never appear in the same update hash. 
        #Names comes from scrapes. Ids come from internal forms.
        if newartistids.nil? == false && newartistcategories.nil? == false
          newartistcategories.pop
          newartistcategories = newartistcategories.split { |i| i == "New Artist"}
          newartistalbums = newartistids.zip(newartistcategories)    
          newartistalbums.each do |artistalbum|
            if artistalbum[0].empty? == false && artistalbum[1].empty? == false
              bitmask = Artist.get_bitmask(artistalbum[1])
              artist = Artist.find_by_id(artistalbum[0])
              if artist.nil? == false
                self.artist_albums.create(:artist_id => artist.id, :category => bitmask)   
              end       
            end
          end 

        end
      #Sources
        #First, update existing sources
          #Grab the remove sources key
          removesources = values.delete :removesources
          #Delete any that are present
          if removesources.nil? == false
            removesources.each do |sourceid|
              self.sources.delete(Source.find_by_id(sourceid))
            end               
          end
        #Now, we add new sources - from scrapes and from forms
          newsources = values.delete :newsources #This is from scrapes
          newsourceids = values.delete :newsourceids #This is from forms
          if newsources.nil? == false
            #remove blanks
            newsources.reject! { |c| c.empty? }
            #Add sources
            newsources.each do |sourcename|
              source = Source.find_by_name(sourcename)
              if source.nil?
                source = Source.new(:name => sourcename, :status => "Unreleased")
                source.save
              end
              self.sources << source
            end
          end   
          if newsourceids.nil? == false
            #remove blanks
            newsourceids.reject! { |c| c.empty? }
            #Add sources
            newsourceids.each do |sourceid|
              source = Source.find_by_id(sourceid)
              if source.nil? == false
                self.sources << source
              end
            end
          end       
      #Organizations
        #First, handle old organizations and update them
          albumorganizations = values.delete :albumorganizations
          #For each source organization id, update it
          if albumorganizations.nil? == false
            albumorganizations.each do |k,v|
              if v['category'].empty? == false
                AlbumOrganization.find_by_id(k).update_attributes(v)
              end
            end
          end      
        #delete the checked relations
          removealbumorganizations = values.delete :removealbumorganizations
          if removealbumorganizations.nil? == false
            removealbumorganizations.each do |each|
              if each.empty? == false
                AlbumOrganization.find_by_id(each).delete
              end
            end
          end
        #Create new AlbumOrganizations
          #Grab the values and categories
          neworganizationnames = values.delete :neworganizationnames #From scrapes
          neworganizationids = values.delete :neworganizationids #From forms
          neworganizationcategories = values.delete :neworganizationcategories
          if neworganizationnames.nil? == false && neworganizationcategories.nil? == false
            neworganizations = neworganizationnames.zip(neworganizationcategories)
            neworganizations.each do |neworganization|
              if neworganization[0].empty? == false && neworganization[1].empty? == false
                organization = Organization.find_by_name(neworganization[0])
                if organization.nil?
                  organization = Organization.new(:name => neworganization[0], :status => "Unreleased")
                  organization.save
                end
                self.album_organizations.create(:organization_id => organization.id, :category => neworganization[1])                    
              end
            end
          end    
          if neworganizationids.nil? == false && neworganizationcategories.nil? == false
            neworganizations = neworganizationids.zip(neworganizationcategories)
            neworganizations.each do |neworganization|
              if neworganization[0].empty? == false && neworganization[1].empty? == false
                organization = Organization.find_by_id(neworganization[0])
                if organization.nil? == false
                  self.album_organizations.create(:organization_id => organization.id, :category => neworganization[1])                    
                end
              end
            end
          end            
      #Songs      
        #There are only new songs in this method.
        newsongs = values.delete :newsongs
        if newsongs.nil? == false
          #If for some reason, newsongs doesn't have tracknumbers and names
          if newsongs['tracknumbers'].nil? == false && newsongs['names'].nil? == false 
            #Namehashes and lengths are not required to be there, fill in 0's and empty hashes if not
            if newsongs['namehashes'].nil?
              newsongs['namehashes'] = Array.new(newsongs['names'].count, {})
            end
            if newsongs['lengths'].nil?
              newsongs['lengths'] = Array.new(newsongs['names'].count, 0)
            end
            #Zip them up
            songinfo = newsongs['tracknumbers'].zip(newsongs['names'], newsongs['lengths'], newsongs['namehashes'])
            songinfo.each do |each|
              #This will also set the length to 0
              self.songs.create(:track_number => each[0], :name => each[1], :length => each[2], :namehash => each[3])
            end
          end
        end
      #Events
        #handle old events
          removeevents = values.delete :removeevents
          #Remove any events that need to be removed
          if removeevents.nil? == false
            removeevents.each do |eventid|
              self.events.delete(Event.find_by_id(eventid))
            end               
          end
        #New Events
          #Grab the array
          neweventshortnames = values.delete :neweventshortnames
          if neweventshortnames.nil? == false
            neweventshortnames.each do |each|
              if each.empty? == false
                event = Event.find_by_shorthand(each)
                if event.nil?
                  event = Event.new(:shorthand => each)
                  event.save
                end
                self.events << event                      
              end
            end
          end
      #Images
        #call the image creation method for solo image upload.
        images = values.delete :images
        if images.nil? == false
          images.each do |image|
            #Check to see if there are any other images already associated to the album
            if self.images.empty?
              #If there aren't any, set the first one to a cover
              flag = 'Cover'
            else
              flag = ''
            end   
            self.upload_image(image,(self.catalog_number + ' - ' + self.id.to_s),'albumart/',flag)
          end
        end          
        #If the image is already saved (as in scrape methods), there will only be names and paths.
        imagenames = values.delete :imagenames
        imagepaths = values.delete :imagepaths
        if imagenames.nil? == false && imagepaths.nil? == false
          images = imagenames.zip(imagepaths)
          images.each do |each|
            if each[0].empty? == false && each[1].empty? == false
              image = Image.new(:name => each[0], :path => each[1])
              self.images << image
              if image.save
                create_image_thumbnails(image)
              end
            end
          end    
          #Marking the first album as a cover
          if self.images.empty? == false
            cover = self.images.first
            if cover.primary_flag != "Cover"
              cover.primary_flag = "Cover"
              cover.save
              create_image_thumbnails(cover)
            end
          end                
        end
      #Related Albums
        #New Related Albums
          albumids = values.delete :newalbumids
          albumcategories = values.delete :newalbumcategories
          #Create the relationship
          if albumids.nil? == false && albumcategories.nil? == false
            self.create_self_relation(albumids,albumcategories,"Album")
          end        
        #Update Related Albums
          relatedalbums = values.delete :relatedalbums
          if relatedalbums.nil? == false
            self.update_related_model(relatedalbums.keys,relatedalbums.values,"Album")
          end        
        #Delete Related Albums
          removerelatedalbums = values.delete :removerelatedalbums
          if removerelatedalbums.nil? == false
            self.delete_related_model(removerelatedalbums,"Album")
          end        
      #Format release date in case it's not a full date. 
        self.format_date_helper("release_date",values)
      # #Update keys with values
        self.update_attributes(values)
    end

  def format_method #for autocomplete
    self.id.to_s + " - " + self.name
  end  
      
  def delete_images #For callback method
    #delete associated images
    self.images.destroy_all
    #delete album folder
    full_path = 'public/images/albumart/' + self.catalog_number + ' - ' + self.id.to_s
    if File.exists?(full_path)
      FileUtils.remove_dir(Rails.root.join(full_path), true)
    end
  end

  #For sorting albums
    def week #For sorting by week
      self.release_date.beginning_of_week(start_day = :sunday)
    end
    
    def month #For sorting by month
      self.release_date.beginning_of_month
    end
    
    def year
      self.release_date.beginning_of_year
    end

  #Sees if the album is in a user's collection 
  #Still not sure if I should pass in a user or user.id. oh well.
    def collected?(user)
      if user.nil?
        false
      else
        self.collections.reject { |a| a.relationship != "Collected"}.map(&:user_id).include?(user.id)        
      end
    end
    
    def ignored?(user)
      if user.nil?
        false
      else
        self.collections.reject { |a| a.relationship != "Ignored"}.map(&:user_id).include?(user.id)
      end
    end
  
    def wishlist?(user)
      if user.nil?
        false
      else
        self.collections.reject { |a| a.relationship != "Wishlist"}.map(&:user_id).include?(user.id)
      end
    end
  
    def collection?(user)
      #returns the type of album-user relationship 
      #if not in collection, returns "" (empty)
      if user.nil? || self.collections.select { |a| a.user_id == user.id}.empty?
        ""
      else
        self.collections.select { |a| a.user_id == user.id}[0].relationship
      end
    end
  
  
  #Limited Edition and reprint check
    def limited_edition?
      self.related_album_relations1.map(&:category).include?("Limited Edition")
    end
  
    def reprint?
      self.related_album_relations1.map(&:category).include?("Reprint")
    end
    
    def alternate_printing?
      self.related_album_relations1.map(&:category).include?("Alternate Printing")      
    end
  
  
  private :delete_images 
  
end