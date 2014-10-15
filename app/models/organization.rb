class Organization < ActiveRecord::Base
  attr_accessible :activity, :altname, :category, :dbcomplete, :established, :info, :name, :privateinfo, :reference, :status, :synopsis, :namehash, :image, :newartistnames, :newartistcategories, :neworganizationnames, :neworganizationcategories, :established_bitmask
  
  serialize :reference
  serialize :namehash

  #Virtual Attributes
    attr_accessor :image, :newartistnames, :newartistcategories, :neworganizationnames, :neworganizationcategories
    #For season/watchlist
    attr_accessor :album_count, :flag
      
  include RelationsModule  
  include ReferencesModule
  include ImagesModule
  include FormattingModule

  #Callbacks
    before_destroy :delete_images
  
  #Categories
    Categories = [["Label"],["Doujin Group"],["Game Company"]]
    SelfRelationships = [["is a parent company of", "Subsidaries", 'Parent Company', "Parent"],
    ['is a subsidary of', '-Parent'], #aka child
    ['was formerly known as', '-Formerly'],
    ['Changed its name to', 'Succeeded By', 'Formerly', 'Formerly'],
    ['was a collaboration of', '-Collab'],
    ['has a collab', 'Collborations', 'Is a Collaboration Of', 'Collab'],
    ['is partners with', 'Partners', 'Partners', 'Partner']]
  
  #Validation
    validates :name, :presence => true 
    validates :status, :presence => true
    validates_uniqueness_of :name, :scope => [:reference]
  
  #Associations
    #Primary Associations
      has_many :related_organization_relations1, class_name: "RelatedOrganizations", foreign_key: 'organization1_id', :dependent => :destroy
      has_many :related_organization_relations2, class_name: "RelatedOrganizations", foreign_key: 'organization2_id', :dependent => :destroy
      has_many :related_organizations1, :through => :related_organization_relations1, :source => :organization2
      has_many :related_organizations2, :through => :related_organization_relations2, :source => :organization1      
      
      def related_organization_relations
        related_organization_relations1 + related_organization_relations2
      end

      def related_organizations
        related_organizations1 + related_organizations2
      end
      
      has_many :album_organizations
      has_many :albums, :through => :album_organizations, dependent: :destroy

      has_many :artist_organizations
      has_many :artists, :through => :artist_organizations, dependent: :destroy
           
      has_many :source_organizations
      has_many :sources, :through => :source_organizations, dependent: :destroy

    #Secondary Associations
      has_many :imagelists, :as => :model
      has_many :images, :through => :imagelists, dependent: :destroy  
      has_many :primary_images, :through => :imagelists, :source => :image, :conditions => "images.primary_flag = 'Primary'" 
    
      has_many :taglists, :as => :subject
      has_many :tags, :through => :taglists, dependent: :destroy
      
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
  
  #Factory Methods!!!!
    def self.full_update(keys,values)
      #This update method will handle adding artists, images and self-related organizations
       if keys.class != Array
        keys = [keys]
      end
      if values.class != Array
        values = [values]
      end
      #Zip up the keys and values
      organizationupdates = keys.zip(values)
      organizationupdates.each do |info|
        #Find the organization
        organization = Organization.find_by_id(info[0])
        if organization.nil? == false
          #Push it over to the full_update_attributes method
          organization.full_update_attributes(info[1])
        end
      end
    end
  
    def full_update_attributes(values)
      #This will update a single record with artists, images, and self-relationed orgs.
      #First, format references
        references = values.delete :reference
        if references.nil? == false
          self.format_references_hash(references[:types],references[:links]) #From the Reference Module
        end    
      #Artists
        #Update Artists
          artistorgs = values.delete :artistorganizations
          if artistorgs.nil? == false
            artistorgs.each do |k,v|
              if v['category'].empty? == false
                ArtistOrganization.find_by_id(k).update_attributes(v)
              end              
            end
          end
        #Delete
          removeartistorgs = values.delete :removeartistorganizations
          if removeartistorgs.nil? == false
            removeartistorgs.each do |each|
              if each.empty? == false
                ArtistOrganization.find_by_id(each).delete
              end
            end
          end
        #New Artists
          newartistids = values.delete :newartistids
          newartistcategories = values.delete :newartistcategories
          if newartistids.nil? == false && newartistcategories.nil? == false
            newartists = newartistids.zip(newartistcategories)
            newartists.each do |newartist|
              if newartist[0].empty? == false and newartist[1].empty? == false
                artist = Artist.find_by_id(newartist[0])
                if artist.nil? == false
                  self.artist_organizations.create(:artist_id => artist.id, :organization_id => self.id, :category => newartist[1])
                end
              end
            end
          end
      #Add the images
        #call the image creation method
        images = values.delete :images
        if images.nil? == false
          images.each do |image|
            self.upload_image(image,self.id.to_s,'orgimages/','Primary')
          end
        end  
      #Related organizations
        #New Related Organizations
        orgids = values.delete :neworganizationids
        orgcategories = values.delete :neworganizationcategories
        if orgids.nil? == false && orgcategories.nil? == false
          self.create_self_relation(orgids,orgcategories,"Organization")
        end    
        #Update related organizations
        relatedorgs = values.delete :relatedorganizations
        if relatedorgs.nil? == false
          self.update_related_model(relatedorgs.keys,relatedorgs.values,"Organization")          
        end
        #Delete any orgs that need to be deleted
        removerelatedorgs = values.delete :removerelatedorganizations
        if removerelatedorgs.nil? == false
          self.delete_related_model(removerelatedorgs,"Organization")
        end
      #Format established date in case it's not a full date. 
        self.format_date_helper("established",values)    
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
    full_path = 'public/images/orgimages/' + self.id.to_s
    if File.exists?(full_path)
      FileUtils.remove_dir(Rails.root.join(full_path), true)
    end
  end

  private :delete_images

end
