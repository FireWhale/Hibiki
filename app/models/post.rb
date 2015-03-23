class Post < ActiveRecord::Base
  #Attributes
    attr_accessible :title, :content,
                    :category, :timestampe,  :visibility, :status,
                    :user_id, :recipient_id, :user_info
  #Modules
    include FormattingModule

  #Callbacks/Hooks
    before_save :parse_content
  
  #Constants
    Categories = ["Scrape Result", "Rescrape Result", 
                  "Luelinks Post", "Records", "Blog Post",
                  "Private Message"]
    Status = ["Released", "Deleted Records"]

    FullUpdateFields = {images: ["id", "postimages/", "Primary"]}  

    FormFields = [{type: "text", attribute: :title, label: "Title:"}, 
                  {type: "select", attribute: :category, label: "Category:", categories: Post::Categories},
                  {type: "select", attribute: :visibility, label: "Visibility:", categories: Ability::Abilities},
                  {type: "select", attribute: :status, label: "Status:", categories: Post::Status},
                  {type: "current_user_id", attribute: :user_id},
                  {type: "images"}, {type: "text_area", attribute: :content, rows: 30, label: "Info:"}]
    
  #Validation
    validates :user, presence: true, if: ->(post){post.category == "Blog Post" || post.category == "Private Message"}
    validates :recipient, presence: true, if: ->(post){post.category == "Private Message"}
    validates :category, inclusion: Post::Categories
    validates :visibility, presence: true
    validates :status, inclusion: Post::Status
    
  #Associations
    has_many :postlists, dependent: :destroy
    
    has_many :imagelists, as: :model, dependent: :destroy
    has_many :images, through: :imagelists
    has_many :primary_images, -> {where "images.primary_flag = 'Primary'" }, through: :imagelists, source: :image

    has_many :taglists, as: :subject
    has_many :tags, through: :taglists, dependent: :destroy

    has_many :albums, through: :postlists, source: :model, source_type: "Album"
    has_many :artists, through: :postlists, source: :model, source_type: "Artist"
    has_many :organizations, through: :postlists, source: :model, source_type: "Organization"
    has_many :songs, through: :postlists, source: :model, source_type: "Song"
    has_many :sources, through: :postlists, source: :model, source_type: "Source"
    
    def primary_records
      albums + artists + organizations + songs + sources
    end
    
    def records
      primary_records + images
    end
    
    belongs_to :user
    belongs_to :recipient, class_name: "User" 

  #Scopes
    scope :scrape_results, -> { where(category: 'Scrape Result')}
    scope :rescrape_results, -> { where(category: 'Rescrape Result')}
    scope :luelinks_posts, -> { where(category: 'Luelinks Post')}
    scope :records, -> { where(category: 'Records')}
    scope :blog_posts, -> { where(category: 'Blog Post')}
    scope :private_messages, -> { where(category: 'Private Message')}
    scope :destroyed_records, -> { where(status: 'Deleted Records')}
    scope :has_tag, ->(tag_id) { joins(:tags).where('tags.id IN (?)', tag_id)}
    scope :meets_security, ->(user) { where('posts.visibility IN (?)', user.nil? ? ["Any"] : user.abilities  )}
    
    def self.scrape_and_rescrape_results
      (scrape_results + rescrape_results)
    end
    
  #Instance Methods
  
  
  #Class Methods    
    def self.cut_messages_for_ll(messages)
      #Takes in an array of messages and makes sure they are less than 9000 characters    
    end

  #Callback methods
    def parse_content
      unless self.content.nil?
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
