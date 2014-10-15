class IssueUser < ActiveRecord::Base
   attr_accessible :issue_id, :user_id, :comment, :vote
  
  belongs_to :issue
  belongs_to :user
end
