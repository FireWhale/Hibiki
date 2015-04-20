class Tag < ActiveRecord::Base
  attr_accessible :name, :info, :synopsis, 
                  :classification, :model_bitmask, :visibility
  
  #Modules
    include FullUpdateModule
  
  #Constants
    ModelBitmask = %w[Album Artist Organization Song Source Post]
    FullUpdateFields = {tag_models: :models}

    FormFields = [{type: "markup", tag_name: "div class='row'"},{type: "markup", tag_name: "div class='col-md-2'"},{type: "markup", tag_name: "/div"},
                  {type: "markup", tag_name: "div class='col-md-8'"},
                  {type: "text", attribute: :name, label: "Name:", field_class: "input-xlarge"},
                  {type: "text", attribute: :classification, label: "Classification:", field_class: "input-xlarge"},
                  {type: "select", attribute: :visibility, label: "Visibility:", categories: Ability::Abilities},
                  {type: "text_area", attribute: :synopsis, rows: 3, label: "Synopsis"},
                  {type: "text_area", attribute: :info, rows: 3, label: "Information:"},
                  {type: "tag_models"},
                  {type: "markup", tag_name: "/div"},
                  {type: "markup", tag_name: "div class='col-md-2'"},{type: "markup", tag_name: "/div"},{type: "markup", tag_name: "/div"}]

  
  #Validation
    validates :name, presence: true , uniqueness: {scope: :model_bitmask}
    validates :classification, presence: true
    validates :model_bitmask, presence: true
    validates :visibility, presence: true, inclusion: Ability::Abilities
    validate :bitmask_check
  
  #Associations
    has_many :taglists, dependent: :destroy
    has_many :albums, :through => :taglists, :source => :subject, :source_type => 'Album'
    has_many :artists, :through => :taglists, :source => :subject, :source_type => 'Artist'
    has_many :organizations, :through => :taglists, :source => :subject, :source_type => 'Organization'
    has_many :sources, :through => :taglists, :source => :subject, :source_type => 'Source'
    has_many :songs, :through => :taglists, :source => :subject, :source_type => 'Song'
    has_many :posts, :through => :taglists, :source => :subject, :source_type => 'Post'
  
  #Scopes
    scope :with_model, ->(models) { where("model_bitmask & ? > 0", Tag.get_bitmask(models)) unless models.nil? }
    scope :meets_security, ->(user) { where('tags.visibility IN (?)', user.nil? ? ["Any"] : user.abilities )}

  def subjects
    taglists.map(&:subject)
  end
    
  def models
    (Tag::ModelBitmask).reject { |r| ((self.model_bitmask || 0 ) & 2**(Tag::ModelBitmask).index(r)).zero?}    
  end
    
  def self.get_bitmask(models)
    models = [models] unless models.class == Array
    (models & Tag::ModelBitmask).map { |r| 2**(Tag::ModelBitmask).index(r) }.sum
  end
  
  def self.get_models(bitmask)
    bitmask = bitmask.to_i if bitmask.class == String
    (Tag::ModelBitmask).reject { |r| ((bitmask || 0 ) & 2**(Tag::ModelBitmask).index(r)).zero?}
  end
  
  private
    def bitmask_check
      errors.add(:base, "This isn't a valid bitmask") unless (self.model_bitmask.nil? == false && self.model_bitmask < 2**Tag::ModelBitmask.count && self.model_bitmask > 0)
    end
  
end
