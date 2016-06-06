module LogModule
  extend ActiveSupport::Concern

  included do
    has_many :loglists, dependent: :destroy, as: :model
    has_many :logs, through: :loglists
  end

end
