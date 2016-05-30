class Post < ActiveRecord::Base

  #Concerns
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
    Status = ["Released", "Has Deleted Records"]

    FormFields = [{type: "text", attribute: :title, label: "Title:"},
                  {type: "select", attribute: :category, label: "Category:", categories: Post::Categories},
                  {type: "select", attribute: :visibility, label: "Visibility:", categories: Ability::Abilities},
                  {type: "select", attribute: :status, label: "Status:", categories: Post::Status},
                  {type: "tags", div_class: "well", title: "Tags"},
                  {type: "images"}, {type: "text_area", attribute: :content, rows: 20, label: "Content:"}]

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
      models + images
    end

  #Scopes
    scope :with_category, ->(categories) { where('category IN (?)', categories)}
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :meets_security, ->(user) { where('posts.visibility IN (?)', user.nil? ? ["Any"] : user.abilities  )}

  #Gem Stuff
    #Pagination
    paginates_per 10

  private
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
              self.tags << record.tags.select { |tag| tag.models.include?("Post") } unless record.class == Image
            end
          end
        end
      end
    end

end
