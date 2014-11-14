class Tag < ActiveRecord::Base
  attr_accessible :classification, :info, :name, :synopsis, :model_bitmask, :visibility
  
  ModelBitmask = %w[Album Artist Organization Song Source]
  
  #Validation
    validates :name, presence: true , uniqueness: {scope: :model_bitmask}
    validates :classification, presence: true
    validates :model_bitmask, presence: true
    validates :visibility, presence: true
    validate :bitmask_check
  

  has_many :taglists, dependent: :destroy
  has_many :albums, :through => :taglists, :source => :subject, :source_type => 'Album'
  has_many :artists, :through => :taglists, :source => :subject, :source_type => 'Artist'
  has_many :organizations, :through => :taglists, :source => :subject, :source_type => 'Organization'
  has_many :sources, :through => :taglists, :source => :subject, :source_type => 'Source'
  has_many :songs, :through => :taglists, :source => :subject, :source_type => 'Song'
  
  def subjects
    albums + artists + organizations + sources + songs
  end
  
  def models
    (Tag::ModelBitmask).reject { |r| ((self.model_bitmask || 0 ) & 2**(Tag::ModelBitmask).index(r)).zero?}    
  end
    
  def self.get_bitmask(models)
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
