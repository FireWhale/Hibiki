class Event < ApplicationRecord
  #Modules
    include AssociationModule #Not used atm, but in the future could add albums through event edit.
    include LanguageModule
    include JsonModule
    include ReferenceModule
    #Associaton Modules
      include LogModule

  #Constants
    FormFields = [{type: "text", attribute: :internal_name, label: "Internal Name:"},
                  {type: "language_fields", attribute: :name},
                  {type: "language_fields", attribute: :abbreviation},
                  {type: "text", attribute: :shorthand, label: "Shorthand:"},
                  {type: "select", attribute: :db_status, label: "Database Status:", categories: Artist::DatabaseStatus},
                  {type: "date", attribute: :start_date, label: "Start Date:"},
                  {type: "date", attribute: :end_date, label: "End Date:"},
                  {type: "references"},
                  {type: "language_fields", attribute: :info}]

  #Associations
    has_many :album_events, dependent: :destroy
    has_many :albums, :through => :album_events

  #Validations
    validates :internal_name, presence: true, uniqueness: true

  #Instance Methods
    def name_helper(*choices) #Name and shortname muddling
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
