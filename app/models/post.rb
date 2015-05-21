class Post < ActiveRecord::Base
  #Attributes
    attr_accessible :title, :content,
                    :category, :timestampe, :visibility, :status
                    
  #Modules
    include FullUpdateModule
    include JsonModule
    #Association Modules
      include ImageModule
      include TagModule

  #Callbacks/Hooks
    before_save :parse_content
  
  #Constants
    Categories = ["Scrape Result", "Rescrape Result", 
                  "Luelinks Post", "Records", "Blog Post",
                  "Private Message"]
    Status = ["Released", "Deleted Records"]

    FullUpdateFields = {images: ["id", "postimages/", "Primary"]}  

    FormFields = [{type: "markup", tag_name: "div class='row'"},{type: "markup", tag_name: "div class='col-md-2'"},{type: "markup", tag_name: "/div"},
                  {type: "markup", tag_name: "div class='col-md-8'"},
                  {type: "text", attribute: :title, label: "Title:"}, 
                  {type: "select", attribute: :category, label: "Category:", categories: Post::Categories},
                  {type: "select", attribute: :visibility, label: "Visibility:", categories: Ability::Abilities},
                  {type: "select", attribute: :status, label: "Status:", categories: Post::Status},
                  {type: "current_user_id", attribute: :user_id},
                  {type: "images"}, {type: "text_area", attribute: :content, rows: 20, label: "Info:"},{type: "markup", tag_name: "/div"},
                  {type: "markup", tag_name: "div class='col-md-2'"},{type: "markup", tag_name: "/div"},{type: "markup", tag_name: "/div"}]
    
  #Validation
    validates :category, inclusion: Post::Categories
    validates :visibility, presence: true, inclusion: Ability::Abilities
    validates :status, inclusion: Post::Status
    
  #Associations
    has_many :postlists, dependent: :destroy
    has_many :albums, through: :postlists, source: :model, source_type: "Album"
    has_many :artists, through: :postlists, source: :model, source_type: "Artist"
    has_many :organizations, through: :postlists, source: :model, source_type: "Organization"
    has_many :songs, through: :postlists, source: :model, source_type: "Song"
    has_many :sources, through: :postlists, source: :model, source_type: "Source"
    
    def models
      postlists.map(&:model)
    end
    
    def records
      primary_records + images
    end

  #Scopes
    scope :with_category, ->(categories) { where('category IN (?)', categories)}
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :meets_security, ->(user) { where('posts.visibility IN (?)', user.nil? ? ["Any"] : user.abilities  )}
        
  #Gem Stuff
    #Pagination
    paginates_per 10
      
  #Class Methods    
    def self.cut_messages_for_ll(messages)
      #Takes in an array of messages and makes sure they are less than 9000 characters    
    end

  #Callback methods
    def parse_content
      unless self.content.blank? || self.content.class != String
        content = self.content
        matches = content.scan(/<record=\"[a-zA-Z]*,\d*.*?\">/)
        matches.each do |match|
          info = match.split("\"")[1].split(",")
          if ["Album", "Artist", "Organization", "Source", "Song", "Image"].include?(info[0])
            record = info[0].constantize.find_by_id(info[1])
            unless record.nil? || self.send("#{info[0].downcase}s").include?(record)
              self.send("#{info[0].downcase}s") << record
              self.add_tags(record) unless record.class == Image
            end
          end
        end
      end
    end
    
    def add_tags(record) #auto adds tags according to record's tags
      valid_tags = record.tags.select { |tag| tag.models.include?("Post") }
      self.tags << valid_tags
    end

end
