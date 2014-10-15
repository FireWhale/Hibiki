class Season < ActiveRecord::Base
  attr_accessible :name, :start_date, :end_date
  
  has_many :source_seasons
  has_many :sources, :through => :source_seasons, dependent: :destroy
end
