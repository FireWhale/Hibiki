class Users::UserRole < ApplicationRecord

  validates :user, presence: true
  validates :role, presence: true
  validates :user_id, uniqueness: {scope: [:role_id]}

  belongs_to :user
  belongs_to :role

end
