class Artist < ActiveRecord::Base
  attr_accessible :activity, :altname, :birthdate, :category, :dbcomplete, :debutdate, :info, :name, :popularity, :privateinfo, :reference, :status, :synopsis, :namehash, :image, :newartistids, :newartistcategories, :neworganizationids, :neworganizationcategories, :birthdate_bitmask, :debutdate_bitmask
  
  serialize :reference
  serialize :namehash

  #Virtual Attributes
    attr_accessor :image, :newartistids, :newartistcategories, :neworganizationids, :neworganizationcategories
    #For season/watchlist
    attr_accessor :album_count, :flag
      
  include RelationsModule  
  include ReferencesModule
  include ImagesModule
  include FormattingModule

  #Callbacks
    before_destroy :delete_images
  
  #Cateogires
  DatabaseStatus = [['Complete'],['Up to Date'],['Ignored'],['Out of Scope'],['Partial'],['Hidden'],['Dead End']]
    #Applies to Artists, Sources, Organizations
      #Complete - Artist/Source/Org is retired or inactive or all official music is released
      #Up to Date - Ongoing series, artist or org is still making music, but all known music is added
      #Ignored - Who cares about this artist/source/org
      
      #Partial - Has been looked at and a few albums added, need to be finished
      #Hidden - Actually hidden from viewing. redirects to alias. E.G. maaya -> maaya sakamoto
      #         These <should> only have one alias or related group. 
      #Dead End - All albums added and is still active, but artist is not followed afterward.
  #Credits/CreditsAbbr are used for ArtistSong and ArtistAlbum credits
    #Database categories
      Credits = %w[Composer Arranger Performer Lyricist FeatComposer FeatArranger FeatPerformer Chorus Instrumentals]  
    #Abbreviations for edting
    CreditsAbbr = %w[Comp Arr Perf Lyr FComp FArr FPerf Chorus Instr.]  
    #Fulls for display
    CreditsFull = {'Composer' =>'Composers', 'Arranger' => 'Arrangers', 'Performer' => 'Performers', 'Lyricist' =>'Lyricists', 'FeatComposer' => 'Featured Composers', 'FeatArranger' => 'Featured Arrangers', 'FeatPerformer' => 'Featured Performers', 'Chorus' => 'Chorus', 'Instrumentals' => 'Instrumentals'}
  
  SelfRelationships = [['is an alias of', '-Alias'],
  ['has an alias called', 'Aliases', 'Aliases', true, true, 'Alias'],
  ['is a member of', '-Member'], #aka Unit
  ['has the member', 'Members', 'Member Of', false, true, 'Member'],
  ['is a subunit of', '-Subunit'],
  ['has the subunit',  'Subunits', 'Subunit of', 'Subunit'],
  ['formerly known as', 'Formerly Known As', 'Now Known As', true, true, 'Former Alias'],
  ['is now known as', '-Former Alias'],
  ['is a former member of', '-Former Member'], #aka Former Unit
  ['had the former member', 'Former Members', 'Former Member Of','Former Member'],
  ['provided the voice of','Voices', 'Voiced by', 'Voice'],
  ['is the voide of','-Voice']]
  
  # #Validation - Whoa. no validation? Okay..I guess. (4/19)
  # validates :name, :presence => true
  # validates :status, :presence => true
  # validates_uniqueness_of :name, :scope => [:reference]
  
  #Associations
    #Primary Associations
      has_many :related_artist_relations1, class_name: 'RelatedArtists', foreign_key: 'artist1_id', :dependent => :destroy
      has_many :related_artist_relations2, class_name: 'RelatedArtists', foreign_key: 'artist2_id', :dependent => :destroy
      has_many :related_artists1, :through => :related_artist_relations1, :source => :artist2
      has_many :related_artists2, :through => :related_artist_relations2, :source => :artist1
 
      def related_artist_relations
        related_artist_relations1 + related_artist_relations2
      end

      def related_artists
        related_artists1 + related_artists2
      end    
            
      has_many :artist_albums
      has_many :albums, :through => :artist_albums, dependent: :destroy
      
      has_many :artist_organizations
      has_many :organizations, :through => :artist_organizations, dependent: :destroy
      
      has_many :artist_songs
      has_many :songs, :through => :artist_songs, dependent: :destroy
    
    #Secondary Associations    
      has_many :taglists, :as => :subject
      has_many :tags, :through => :taglists, dependent: :destroy
      
      has_many :imagelists, :as => :model
      has_many :images, :through => :imagelists, dependent: :destroy  
      has_many :primary_images, :through => :imagelists, :source => :image, :conditions => "images.primary_flag = 'Primary'" 
   
   #User Associations
      has_many :watchlists, :as => :watched
      has_many :users, :through => :watchlists, dependent: :destroy   

  #Gem Stuff
    #Pagination
      paginates_per 50
  
    #Sunspot Searching
      searchable do
        text :namehash,  :boost => 5
        text :name, :altname
        text :reference
      end
  
  #For Artist and Album/Song Relationship categories
    def self.get_bitmask(categories)
      (categories & Artist::Credits).map { |r| 2**(Artist::Credits).index(r) }.sum
    end
    
    def self.get_categories(bitmask)
      if bitmask.class == String
        bitmask = bitmask.to_i
      end
      (Artist::Credits).reject { |r| ((bitmask || 0 ) & 2**(Artist::Credits).index(r)).zero?}
    end
  
  #Factory Methods
    def self.full_update(keys, values)
      #This update covers Images, Organizations, and self artist relationships
        if keys.class != Array
          keys = [keys]
        end
        if values.class != Array
          values = [values]
        end
        #Zip up the keys and values
        artistupdates = keys.zip(values)
        artistupdates.each do |info|
          artist = Artist.find_by_id(info[0])
          if artist.nil? == false
            #If the artist exists, push the data to full_update_attributes
            artist.full_update_attributes(info[1])
          end
        end
    end
    
    def full_update_attributes(values)
      #This full update covers images, organizations, and self-related artists
      #First, format references
        references = values.delete :reference
        if references.nil? == false
          self.format_references_hash(references[:types],references[:links]) #From the Reference Module
        end      
      #Organizations
        #First, handle old organizations and update them
          artistorganizations = values.delete :artistorganizations
          #For each source organization id, update it
          if artistorganizations.nil? == false
            artistorganizations.each do |k,v|
              if v['category'].empty? == false
                ArtistOrganization.find_by_id(k).update_attributes(v)
              end
            end
          end
          #delete the checked relations
          removeartistorganizations = values.delete :removeartistorganizations
          if removeartistorganizations.nil? == false
            removeartistorganizations.each do |each|
              if each.empty? == false
                ArtistOrganization.find_by_id(each).delete
              end
            end
          end
        #then handle new organizations
          #Grab the values and categories
          neworganizationids = values.delete :neworganizationids
          neworganizationcategories = values.delete :neworganizationcategories
          if neworganizationids.nil? == false && neworganizationcategories.nil? == false
            neworganizations = neworganizationids.zip(neworganizationcategories)
            neworganizations.each do |neworganization|
              if neworganization[0].empty? == false && neworganization[1].empty? == false
                organization = Organization.find_by_id(neworganization[0])
                if organization.nil? == false
                  self.artist_organizations.create(:organization_id => organization.id, :category => neworganization[1])                    
                end
              end
            end
          end                  
      #Add the images
        #call the image creation method
        images = values.delete :images
        if images.nil? == false
          images.each do |image|
            self.upload_image(image,self.id.to_s,'artistimages/','Primary')
          end
        end
      #Related Artists
        #New Artists
          artistids = values.delete :newartistids
          artistcategories = values.delete :newartistcategories
          #Create the relationship
          if artistids.nil? == false && artistcategories.nil? == false
            self.create_self_relation(artistids,artistcategories,"Artist")
          end
        #Handle updating related artists
          relatedartists = values.delete :relatedartists
          if relatedartists.nil? == false
            self.update_related_model(relatedartists.keys,relatedartists.values,"Artist")
          end
        #Delete any relations that need to be deleted
          removerelatedartists = values.delete :removerelatedartists
          if removerelatedartists.nil? == false
            self.delete_related_model(removerelatedartists,"Artist")
          end
      #Format birth date and debut date in case it's not a full date. 
        self.format_date_helper("birthdate",values)
        self.format_date_helper("debutdate",values)
      #Finally, update the key with the values
        self.update_attributes(values)
    end

  def format_method #for autocomplete
    self.id.to_s + " - " + self.name
  end  
  
  def delete_images #For callback method
    #delete associated images
    self.images.destroy_all
    #delete album folder
    full_path = 'public/images/artistimages/' + self.id.to_s
    if File.exists?(full_path)
      FileUtils.remove_dir(Rails.root.join(full_path), true)
    end
  end

  private :delete_images
end
