class Season < ActiveRecord::Base
  attr_accessible :name, :start_date, :end_date
  
  #Associations
    has_many :source_seasons
    has_many :sources, :through => :source_seasons, dependent: :destroy
  
  #Validations
    validates :start_date, presence: true
    validates :end_date, presence: true
    validates :name, presence: true
end
