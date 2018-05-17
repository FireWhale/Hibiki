class Loglist < ApplicationRecord
  belongs_to :log
  belongs_to :model, polymorphic: :true

  #Validations
    validates :log_id, uniqueness: {scope: [:model_id, :model_type]}
    validates :log, presence: true
    validates :model, presence: true
end
