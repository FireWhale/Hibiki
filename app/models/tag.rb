class Tag < ApplicationRecord

  #Concerns
    include LanguageModule
    include JsonModule

    default_scope { includes(:translations) }

  #Attributes
    attr_accessor :tag_models

  #Callbacks/Hooks
    before_validation :convert_models_to_bitmask

  #Constants
    ModelBitmask = %w[Album Artist Organization Song Source Post]

    FormFields = [{type: "text", attribute: :internal_name, label: "Internal Name:", field_class: "input-xlarge"},
                  {type: "language_fields", attribute: :name},
                  {type: "text", attribute: :classification, label: "Classification:", field_class: "input-xlarge"},
                  {type: "select", attribute: :visibility, label: "Visibility:", categories: Ability::Abilities},
                  {type: "language_fields", attribute: :info},
                  {type: "tag_models"},]

  #Validation
    validates :internal_name, presence: true , uniqueness: {scope: :model_bitmask}
    validates :classification, presence: true
    validates :model_bitmask, presence: true
    validates :visibility, presence: true, inclusion: Ability::Abilities
    validate :bitmask_check

  #Associations
    has_many :taglists, dependent: :destroy
    has_many :albums, :through => :taglists, :source => :subject, :source_type => 'Album'
    has_many :artists, :through => :taglists, :source => :subject, :source_type => 'Artist'
    has_many :organizations, :through => :taglists, :source => :subject, :source_type => 'Organization'
    has_many :sources, :through => :taglists, :source => :subject, :source_type => 'Source'
    has_many :songs, :through => :taglists, :source => :subject, :source_type => 'Song'
    has_many :posts, :through => :taglists, :source => :subject, :source_type => 'Post'

  #Scopes
    scope :with_model, ->(models) { where("model_bitmask & ? > 0", Tag.get_bitmask(models)) unless models.nil? }
    scope :meets_security, ->(user) { where('tags.visibility IN (?)', user.nil? ? ["Any"] : user.abilities )}

  def subjects
    taglists.map(&:subject)
  end

  def models
    Tag.get_models(self.model_bitmask)
  end

  def self.get_bitmask(models)
    models = [models] unless models.class == Array
    (models & Tag::ModelBitmask).map { |r| 2**(Tag::ModelBitmask).index(r) }.sum
  end

  def self.get_models(bitmask)
    bitmask = bitmask.to_i if bitmask.class == String
    (Tag::ModelBitmask).reject { |r| ((bitmask || 0 ) & 2**(Tag::ModelBitmask).index(r)).zero?}
  end

  private
    def bitmask_check
      errors.add(:base, "This isn't a valid bitmask") unless (self.model_bitmask.nil? == false && self.model_bitmask < 2**Tag::ModelBitmask.count && self.model_bitmask > 0)
    end

    def convert_models_to_bitmask
      self.model_bitmask = Tag.get_bitmask(self.tag_models) unless tag_models.blank?
    end
end
