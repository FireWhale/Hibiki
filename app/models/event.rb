class Event < ActiveRecord::Base
  attr_accessible :abbreviation, :altname, :dbcomplete, :enddate, :info, :name, :reference, :shorthand, :startdate
  serialize :reference

  include ReferencesModule

  has_many :album_events
  has_many :albums, :through => :album_events, dependent: :destroy  
  
  #Factory Method - Needed for Reference
    def self.full_update(keys,values)
      #This will format and update references included in the event hash
        if keys.class != Array
          keys = [keys]
        end
        if values.class != Array
          values = [values]
        end      
        #Zip up the keys and values and iterate through them.
        eventupdates = keys.zip(values)
        eventupdates.each do |info|
          #Find the album
          event = Event.find_by_id(info[0])
          if event.nil? == false
            #If the event exists, push it over to the instance method full_update_attributes
            event.full_update_attributes(info[1])
          end
        end         
    end
    
    def full_update_attributes(values)
      #Only needed for references, but whatever. May include albums at some point.
      #First, format references
        references = values.delete :reference
        if references.nil? == false
          self.format_references_hash(references[:types],references[:links]) #From the Reference Module
        end    
      #Then, update keys with values
        self.update_attributes(values)        
    end
end
