class Users::Role < ApplicationRecord

  validates :name, presence: true, uniqueness: true, inclusion: Rails.application.secrets.roles
  validates :description, presence: true

  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

end
