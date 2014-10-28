class IssueUser < ActiveRecord::Base
   attr_accessible :issue_id, :user_id, :comment, :vote
  
  validates :issue, :presence => true
  validates :user, :presence => true
  
  validates :comment, presence: true, unless:  ->(issue_user){issue_user.vote.present?}
  validates :vote, presence: true, unless:  ->(issue_user){issue_user.comment.present?}
  
  belongs_to :issue
  belongs_to :user
end
