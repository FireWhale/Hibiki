class Issue < ApplicationRecord
  #Concerns
    include JsonModule
  
  #Constants
    Categories = ["Bug Report", "Feature Request", "Code Change"]
    Status = ["Open", "Closed", "Proposed", "Working On"]
    Resolutions = ["Fixed", "Filled", "Can't Reproduce", "Won't Fix"]
    Priorities = ["High", "Medium", "Low"]
    Difficulties = ["Easy", "Medium", "Hard"]
    
    FormFields = [{type: "text", attribute: :name, label: "Name:", field_class: "input-xlarge"},
                  {type: "select", attribute: :status, label: "Status:", categories: Issue::Status},
                  {type: "select", attribute: :category, label: "Category:", categories: Issue::Categories},
                  {type: "select", attribute: :visibility, label: "Visibility:", categories: Rails.application.secrets.roles},
                  {type: "select", attribute: :resolution, label: "Resolution:", categories: Issue::Resolutions},
                  {type: "select", attribute: :difficulty, label: "Difficulty:", categories: Issue::Difficulties},
                  {type: "select", attribute: :priority, label: "Priority:", categories: Issue::Priorities},
                  {type: "text_area", attribute: :description, rows: 6, label: "Description:"},
                  {type: "text_area", attribute: :private_info, rows: 6, label: "Private Information:"}]
    
  #Validations
    validates :name, presence: true
    validates :category, presence: true, inclusion: Issue::Categories
    validates :visibility, presence: true, inclusion: Rails.application.secrets.roles
    validates :status, presence: true, inclusion: Issue::Status
        
  #Scope
    scope :with_category, ->(categories) { where('category IN (?)', categories)}
    scope :with_status, ->(statuses) {where('status IN (?)', statuses)}
    scope :with_priority, ->(priorities) {where('priority IN (?)', priorities)}
    scope :with_difficulty, ->(difficulties) {where('difficulty IN (?)', difficulties)}
    scope :meets_role, ->(user) { where('issues.visibility IN (?)', user.nil? ? ["Any"] : user.abilities  )}

  #Gem Stuff
    #Pagination
    paginates_per 10
end
