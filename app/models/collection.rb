class Collection < ActiveRecord::Base
  attr_accessible :collected_id, :collected_type, :rating, :relationship, :user_comment, :date_obtained
  
  Relationship = %w[Collected Ignored Wishlisted]
  
  validates :collected_type, inclusion: %w[Album Song]
  validates :user, presence: true
  validates :collected, presence: true
  validates_uniqueness_of :user_id, :scope => [:collected_id, :collected_type]
  validates :relationship, presence: true, inclusion: Collection::Relationship

  validates :date_obtained, presence: true, unless: -> {self.date_obtained_bitmask.nil?}
  validates :date_obtained_bitmask, presence: true, unless: -> {self.date_obtained.nil?}


  belongs_to :collected, polymorphic: true
  belongs_to :user
  
end
