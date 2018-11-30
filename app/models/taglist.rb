class Taglist < ApplicationRecord

  include NeoRelModule

  attr_accessor :_destroy

  #Validation
    validates :tag, presence: true
    validates :subject, presence: true
    validates :subject_id, uniqueness: {scope: [:subject_type, :tag_id]}
    validate :validate_models
    
  belongs_to :tag
  belongs_to :subject, polymorphic: true

  def neo_relation
    neo_rel(tag,subject)
  end

  private  
    def validate_models
      #This checks to make sure the tag has the model in it's models
      return unless errors.blank?
      errors.add(:base, "This tag is not a valid tag for this model") unless self.tag.models.include?(self.subject.class.to_s)
    end


end
