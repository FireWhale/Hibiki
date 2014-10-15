class Tag < ActiveRecord::Base
  attr_accessible :classification, :info, :name, :synopsis, :model_bitmask
  
  # #Validation
  # validates :name, :presence => true 
  
  ModelBitmask = %w[Album Artist Organization Song Source]

  has_many :taglists
  has_many :albums, :through => :taglists, :source => :subject, :source_type => 'Album'
  has_many :artists, :through => :taglists, :source => :subject, :source_type => 'Artist'
  has_many :organizations, :through => :taglists, :source => :subject, :source_type => 'Organization'
  has_many :sources, :through => :taglists, :source => :subject, :source_type => 'Source'
  has_many :songs, :through => :taglists, :source => :subject, :source_type => 'Song'
  
  def subjects
    albums + artists + organizations + sources + songs
  end
  
  def self.get_bitmask(models)
    (models & Tag::ModelBitmask).map { |r| 2**(Tag::ModelBitmask).index(r) }.sum
  end
  
  def self.get_models(bitmask)
    if bitmask.class == String
      bitmask = bitmask.to_i
    end
    (Tag::ModelBitmask).reject { |r| ((bitmask || 0 ) & 2**(Tag::ModelBitmask).index(r)).zero?}
  end
  
  def get_models
    Tag.get_models(self.model_bitmask)
  end
  
end
