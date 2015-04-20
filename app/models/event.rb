class Event < ActiveRecord::Base
  #Attributes
    attr_accessible :name, :abbreviation, :altname, :shorthand, 
                    :info, :db_status, :reference,
                    :start_date, :end_date
                    
    serialize :reference
  
  #Modules
    include FullUpdateModule
    include LanguageModule
    
  #Constants
    FullUpdateFields = {reference: true}    
    
    FormFields = [{type: "text", attribute: :name, label: "Name:"}, 
                  {type: "text", attribute: :altname, label: "Alt Name:"},
                  {type: "text", attribute: :abbreviation, label: "Abbreviation:"},
                  {type: "text", attribute: :shorthand, label: "Shorthand:"}, 
                  {type: "select", attribute: :db_status, label: "Database Status:", categories: Artist::DatabaseStatus},
                  {type: "date", attribute: :start_date, label: "Start Date:"}, 
                  {type: "date", attribute: :end_date, label: "End Date:"}, 
                  {type: "references"},
                  {type: "text_area", attribute: :info, rows: 4, label: "Info:"},
                  ] 
    
  #Associations
    has_many :album_events, dependent: :destroy  
    has_many :albums, :through => :album_events

  #Validations
    validates :name, presence: true, unless:  ->(event){event.shorthand.present?}
    validates :shorthand, presence: true, unless:  ->(event){event.name.present?}
  
  #Instance Methods
    #Name and shortname muddling
      def name_helper(*choices)
        choices.each do |choice|
          if self.respond_to?(choice) && self.send("#{choice}?")
            return self.send(choice)
          end
        end
        nil
      end      
end
