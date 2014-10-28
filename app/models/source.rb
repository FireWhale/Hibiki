class Source < ActiveRecord::Base
  attr_accessible :activity, :altname, :category, :db_status, :info, :name, :popularity, :privateinfo, :reference, :releasedate, :enddate, :format, :status, :synopsis, :namehash, :image, :newsourcenames, :newsourcecategories, :neworganizationnames, :neworganizationcategories, :releasedate_bitmask
  
  serialize :reference
  serialize :namehash

  #Virtual Attributes
    #For creating/updating
    attr_accessor :image, :newsourcenames, :newsourcecategories, :neworganizationnames, :neworganizationcategories
    #For season/watchlist
    attr_accessor :album_count, :flag
  
  include RelationsModule  
  include ReferencesModule
  include ImagesModule
  include FormattingModule
  
  #Callbacks
    before_destroy :delete_images  
    
  #Categories
    Categories = [["Franchise"],["Product"]]
    SelfRelationships = [['is a prequel of', 'Sequel', 'Prequel', 'Prequel'],
    ['is a sequel of', '-Prequel'], #aka sequel
    ['is adapted as', 'Adpated As', 'An Adaption Of', 'Adaptation'],
    ['is an adaptation of', '-Adaptation'],
    ['has the same setting as', 'Same Setting', 'Same Setting', 'Same Setting'], #order doesn't matter
    ['shares characters with', 'Shares Characters', 'Shares Characters', 'Shares Characters'], #order doesn't matter
    ['is the parent story of', 'Side Story', 'Parent Story', 'Parent Story'], 
    ['has the fandisc', '-Fan Disc'],
    ['is a fandisc of', 'Original Story', 'Fan Disc', 'Fan Disc'],
    ['\'s franchise includes', 'Franchise Includes', 'Part of Franchie', 'Franchise'],
    ['is part of the franchise', '-Franchise'],
    ['is a side story of', '-Parent Story'], #aka Side Story
    ['is in the same series as', 'Same Series', 'Same Series', 'Same Series'], #order doesn't matter
    ['is an alternate version of', 'Alternate Version', 'Alternate Version', 'Alternate Version'],
    ['is in an alternate setting of', 'Alternate Setting', 'Alternate Setting', 'Alternate Setting']] #order doesn't matter
  
  #Validation
  validates :name, :presence => true 
  validates :status, :presence => true
  validates_uniqueness_of :name, :scope => [:reference]
  
  #Associations
    #Primary Aassociations
      has_many :related_source_relations1, class_name: "RelatedSources", foreign_key: 'source1_id', :dependent => :destroy
      has_many :related_source_relations2, class_name: "RelatedSources", foreign_key: 'source2_id', :dependent => :destroy
      has_many :related_sources1, :through => :related_source_relations1, :source => :source2
      has_many :related_sources2, :through => :related_source_relations2, :source => :source1
      
      def related_source_relations
        related_source_relations1 + related_source_relations2
      end
      
      def related_sources
        related_sources1 + related_sources2
      end
    
      has_many :album_sources
      has_many :albums, :through => :album_sources, dependent: :destroy
      
      has_many :source_organizations
      has_many :organizations, :through => :source_organizations, dependent: :destroy
      
      has_many :song_sources
      has_many :songs, :through => :song_sources, dependent: :destroy
        
    #Secondary Associations
      has_many :taglists, :as => :subject
      has_many :tags, :through => :taglists, dependent: :destroy
      
      has_many :imagelists, :as => :model
      has_many :images, :through => :imagelists, dependent: :destroy  
      has_many :primary_images, :through => :imagelists, :source => :image, :conditions => "images.primary_flag = 'Primary'" 
    
      has_many :source_seasons
      has_many :seasons, :through => :source_seasons, dependent: :destroy
    
    #User Associations
      has_many :watchlists, :as => :watched
      has_many :users, :through => :watchlists, dependent: :destroy
      
      
  #Gem Stuff
    #Pagination    
      paginates_per 50
      
    #Sunspot Searching
      searchable do
        text :name, :altname, :namehash, :boost => 5
        text :reference
      end
  
  #Factory Methods
    def self.full_update(keys, values)
      #This update method will handle adding organizations, related sources, and images 
      #First, address if there's only one key and value. Put them into an array.
        if keys.class != Array
          keys = [keys]
        end
        if values.class != Array
          values = [values]
        end
        #Zip up the keys and values and iterate through them.
        sourceupdates = keys.zip(values)
        sourceupdates.each do |info|
          #Find the source:
          source = Source.find_by_id(info[0])
          if source.nil? == false
            #If the source exists, push it over to the instance method full_update_attributes
            source.full_update_attributes(info[1])
          end
        end
    end
    
    def full_update_attributes(values)
      #This update method will handle adding organizations, related sources, and images to a single source  
      #First, format references
        references = values.delete :reference
        if references.nil? == false
          self.format_references_hash(references[:types],references[:links]) #From the Reference Module
        end
      #Organizations
        #First, handle old organizations and update them
          sourceorganizations = values.delete :sourceorganizations
          #For each source organization id, update it
          if sourceorganizations.nil? == false
            sourceorganizations.each do |k,v|
              if v['category'].empty? == false
                SourceOrganization.find_by_id(k).update_attributes(v)
              end
            end
          end
          #delete the checked relations
          removesourceorganizations = values.delete :removesourceorganizations
          if removesourceorganizations.nil? == false
            removesourceorganizations.each do |each|
              if each.empty? == false
                SourceOrganization.find_by_id(each).delete
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
                  self.source_organizations.create(:organization_id => organization.id, :category => neworganization[1])                    
                end
              end
            end
          end
      #Add the images
        #call the image creation method
        images = values.delete :images
        if images.nil? == false
          images.each do |image|
            self.upload_image(image,self.id.to_s,'sourceimages/','Primary')
          end
        end          
      #Add related sources
        #Grab the names and categories for new sources
          sourceids = values.delete :newsourceids
          sourcecategories = values.delete :newsourcecategories
          #Create the relationship
          if sourceids.nil? == false && sourcecategories.nil? == false
            self.create_self_relation(sourceids,sourcecategories,"Source")
          end
        #Handle updating related sources
          relatedsources = values.delete :relatedsources
          if relatedsources.nil? == false
            self.update_related_model(relatedsources.keys,relatedsources.values,"Source")
          end
        #Delete any sources that need to be deleted
          removerelatedsources = values.delete :removerelatedsources
          if removerelatedsources.nil? == false
            self.delete_related_model(removerelatedsources,"Source")
          end
      #Format release date in case it's not a full date. 
        self.format_date_helper("releasedate",values)
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
    full_path = 'public/images/sourceimages/' + self.id.to_s
    if File.exists?(full_path)
      FileUtils.remove_dir(Rails.root.join(full_path), true)
    end
  end

  private :delete_images

end
