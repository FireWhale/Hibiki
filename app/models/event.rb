class Event < ActiveRecord::Base
  attr_accessible :name, :abbreviation, :altname, :shorthand, :start_date, 
                  :end_date, :info, :db_status, :reference
                  
  serialize :reference

  include ReferencesModule

  has_many :album_events, dependent: :destroy  
  has_many :albums, :through => :album_events

  #Validations
    validates :name, presence: true, unless:  ->(event){event.shorthand.present?}
    validates :shorthand, presence: true, unless:  ->(event){event.name.present?}
  
  #Instance Methods
    #Name and shortname muddling
      def name_or_shorthand
        self.name? ? self.name : self.shorthand
      end
  
      def shorthand_or_name
        self.shorthand? ? self.shorthand : self.name 
      end
      
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
