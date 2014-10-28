class Issue < ActiveRecord::Base
  attr_accessible :name, :category, :description, 
                  :resolution, :private_info, :status, 
                  :priority, :visibility, :difficulty
  
  #Constants
    Categories = ["Bug Report", "Feature Request", "Code Change"]
    Statuses = ["Open", "Closed", "Proposed", "Working On"]
    Resolutions = ["Fixed", "Filled", "Can't Reproduce", "Won't Fix"]
    Priorities = ["High", "Medium", "Low"]
    Difficulties = ["Easy", "Medium", "Hard"]
    
  #Validations
    validates :name, presence: true
    validates :category, presence: true
    validates :visibility, presence: true
    validates :status, presence: true
    
  #Associations
    has_many :issue_users, dependent: :destroy
end
