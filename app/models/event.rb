class Event < ActiveRecord::Base
  #Attributes
    attr_accessible :name, :abbreviation, :altname, :shorthand, 
                    :info, :db_status, :reference,
                    :start_date, :end_date
                    
    serialize :reference
  
  #Modules
    include FormattingModule
    
  #Constants
    FullUpdateFields = {reference: true}    
    
  #Associations
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
      
end
