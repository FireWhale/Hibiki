class Event < ActiveRecord::Base
  #Attributes
    attr_accessible :internal_name, :shorthand, 
                    :info, :db_status,
                    :start_date, :end_date
                    
  #Modules
    include FullUpdateModule
    include LanguageModule
    include JsonModule
    include ReferenceModule
    
  #Constants
    FullUpdateFields = {reference: true, languages: [:name, :info, :abbreviation]}    
    
    FormFields = [{type: "markup", tag_name: "div class='row'"},{type: "markup", tag_name: "div class='col-md-2'"},{type: "markup", tag_name: "/div"},
                  {type: "markup", tag_name: "div class='col-md-8'"},
                  {type: "text", attribute: :internal_name, label: "Internal Name:"}, 
                  {type: "language_fields", attribute: :name},
                  {type: "language_fields", attribute: :abbreviation},
                  {type: "text", attribute: :shorthand, label: "Shorthand:"}, 
                  {type: "select", attribute: :db_status, label: "Database Status:", categories: Artist::DatabaseStatus},
                  {type: "date", attribute: :start_date, label: "Start Date:"}, 
                  {type: "date", attribute: :end_date, label: "End Date:"}, 
                  {type: "references"},
                  {type: "language_fields", attribute: :info},{type: "markup", tag_name: "/div"},
                  {type: "markup", tag_name: "div class='col-md-2'"},{type: "markup", tag_name: "/div"},{type: "markup", tag_name: "/div"}] 
    
  #Associations
    has_many :album_events, dependent: :destroy  
    has_many :albums, :through => :album_events

  #Validations
    validates :internal_name, presence: true, uniqueness: true
  
  #Instance Methods
    #Name and shortname muddling
      def name_helper(*choices)
        choices.each do |choice|
          if self.respond_to?(choice) && self.send("#{choice}").blank? == false
            if choice == "read_abbreviation" || choice == "read_name"
              return self.send(choice)[0]
            else
              return self.send(choice)
            end
          end
        end
        nil
      end      
end
