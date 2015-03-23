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
    validates :category, presence: true, inclusion: Issue::Categories
    validates :visibility, presence: true
    validates :status, presence: true, inclusion: Issue::Statuses
    
  #Associations
    has_many :issue_users, dependent: :destroy
    
  #Scope
    scope :bug_reports, -> { where(category: "Bug Report")}
    scope :feature_requests, -> { where(category: "Feature Request")}
    scope :code_changes, -> { where(category: "Code Change")}
    scope :category, ->(category) { where(category: category)}
    scope :status, ->(status) { where(status: status)}
    scope :meets_security, ->(user) { where('issues.visibility IN (?)', user.nil? ? ["Any"] : user.abilities  )}
end
