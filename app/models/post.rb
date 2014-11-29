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
    has_many :primary_images, through: :imagelists, source: :image, conditions: "images.primary_flag = 'Primary'" 

    has_many :albums, through: :postlists, source: :model, source_type: "Album"
    has_many :artists, through: :postlists, source: :model, source_type: "Artist"
    has_many :organizations, through: :postlists, source: :model, source_type: "Organization"
    has_many :songs, through: :postlists, source: :model, source_type: "Song"
    has_many :sources, through: :postlists, source: :model, source_type: "Source"
    
    def primary_records
      albums + artists + organizations + songs + sources
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
    
    def self.scrape_and_rescrape_results
      (scrape_results + rescrape_results)
    end
    
  #Instance Methods
    def upload_image_to_ll(image, topicid)
      
    end
    
    def add_record_to_post
      #Used as a callback. 
      #This is only used for blog posts, but it'll link parse the post's content
      #for records mentions and it will add it to the post. The record will 
      #then list out the Blog Posts it has been mentioned in
      
    end
    
  #Class Methods    
    def self.cut_messages_for_ll(messages)
      #Takes in an array of messages and makes sure they are less than 9000 characters    
    end

  #Callback methods
    def parse_content
      unless self.content.nil?
        content = self.content
        #Match records
          matches = content.scan(/<record=\"[a-zA-Z]*,\d*\">/)
          matches.each do |match|
            info = match.split("\"")[1].split(",")
            if ["Album", "Artist", "Organization", "Source", "Song"].include?(info[0])
              record = info[0].constantize.find_by_id(info[1])
              self.send("#{info[0].downcase}s") << record unless record.nil?
            end
          end
        #match Images
          image_matches = content.scan(/<image=\"\d*\">/)
          image_matches.each do |match|
            record = Image.find_by_id(match.split("\"")[1])
            self.images << record unless record.nil?
          end
      end
    end


end
