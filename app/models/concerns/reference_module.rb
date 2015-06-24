module ReferenceModule
  extend ActiveSupport::Concern
  
  included do
    has_many :references, dependent: :destroy, as: :model
  end
  
  def references(*site_name)
    return super if site_name.empty?
    references.select { |ref| ref.site_name == site_name.first.to_s }.first
  end
end
