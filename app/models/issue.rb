class Issue < ActiveRecord::Base
  attr_accessible :name, :category, :description, :resolution, :private_info, :status, :priority, :visibility
  
  Categories = ["Bug Report", "Feature Request"]
  Statuses = ["Open", "Closed", "Proposed", "Working On"]
  Resolutions = ["Fixed", "Filled", "Can't Reproduce", "Won't Fix"]
end
