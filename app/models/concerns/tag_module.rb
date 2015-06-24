module TagModule
  extend ActiveSupport::Concern
  
  included do
    has_many :taglists, dependent: :destroy, as: :subject
    has_many :tags, through: :taglists

    scope :with_tag, ->(tag_ids) {joins(:taglists).where('taglists.tag_id IN (?)', tag_ids).distinct unless tag_ids.nil?}    
  end
  
end
