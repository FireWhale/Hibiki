module ReferenceModule
  extend ActiveSupport::Concern

  included do
    has_many :references, dependent: :destroy, as: :model

    attr_accessor :new_references
    attr_accessor :update_references

    after_save :manage_references
  end

  def references(*site_name)
    return super if site_name.empty?
    references.select { |ref| ref.site_name == site_name.first.to_s }.first
  end

  private
    def manage_references
      new_references = HashWithIndifferentAccess.new(self.new_references)
      unless new_references.blank?
        new_references[:site_name].zip(new_references[:url]).each do |reference|
          self.references.create(site_name: reference[0], url: reference[1]) unless reference[0].blank? || reference[1].blank?
        end
      end
      update_references = HashWithIndifferentAccess.new(self.update_references)
      unless update_references.blank?
        update_references.each do |id, info|
          reference = self.references.find_by_id(id.to_s)
          (info[:site_name].blank? || info[:url].blank? ? reference.destroy : reference.update_attributes(info)) unless reference.nil?
        end
      end
    end
end
