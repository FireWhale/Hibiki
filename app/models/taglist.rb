class Taglist < ActiveRecord::Base
  attr_accessible :tag_id, :subject_id, :subject_type
  
  validate :validate_models
  
  belongs_to :tag
  belongs_to :subject, polymorphic: true
  
  validates_uniqueness_of :subject_id, scope: [:subject_type, :tag_id]
  
  def validate_models
    #This checks to make sure the tag has the model in it's models
    errors.add("This tag is not a valid tag for this model") unless self.tag.get_models.include?(self.subject.class.to_s)
  end
  
end
