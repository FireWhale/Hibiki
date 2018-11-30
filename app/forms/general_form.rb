class GeneralForm
  include ActiveModel::Model

  attr_accessor :log
  attr_accessor :record


  validates :record, presence: true

  def save
    valid? && persist
  end

  #def save! #unused method. Keep?
    #valid? && persist!
  #end

  #def persisted? #unused method. keep?
    #false
  #end

  def record_attributes=(attributes) #takes form attributes and attaches to form object on instantiation
    @attribute_record = model.new(attributes)
  end

  def references_attributes=(attributes)
    @references ||= []
    attributes.each do |k, ref|
      @references.push(Reference.new(ref))
    end
  end

  def images_attributes=(attributes)
    @images ||= []
    attributes.each do |k, image|
      @images.push(Image.new(image))
    end
  end

  #Not gonna persist image uploads in cases of error. not safe for user.

  def taglists_attributes=(attributes)
    @taglists ||= []
    attributes.each do |k, taglist|
      @taglists.push(Taglist.new(taglist))
    end
  end

  def translations_attributes=(attributes)
    @translations ||= []
    attributes.each do |k, trans|
      @translations.push(model::Translation.new(trans))
    end
  end

  def self_relations_attributes=(attributes)
    @self_relations ||= []
    attributes.each do |k, rel|
      @self_relations.push("Related#{model}s".constantize.new(rel))
    end
  end

  def artist_organizations_attributes=(attributes)
    @artist_organizations ||= []
    attributes.each do |k, art_org|
      @artist_organizations.push(ArtistOrganization.new(art_org))
    end
  end

  def self.reflect_on_association(klass) #For adding new records javascript
    data = { klass: klass }
    OpenStruct.new data
  end

  private
    def persist
      ActiveRecord::Base.transaction do
        transaction #defined in child classes
      end
      upload_images(@record,@new_images) if @record.respond_to?(:images) && !@new_images.blank?
      true
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)
      false
    end

    def manage_references(record,references)
      references.each do |ref|
        if ref.id.blank? #new reference
          record.references.create!(ref.slice(:url, :site_name)) unless ref.site_name.blank? || ref.url.blank?
        else
          reference = record.references.find_by_id(ref.id)
          (ref.site_name.blank? || ref.url.blank? || ref._destroy.to_i == 1 ? reference.destroy! : reference.update_attributes!(ref.slice(:url, :site_name))) unless reference.nil?
        end
      end
    end

    def manage_translations(record,translations,fields)
      translations.each do |trans|
        if LanguageModule::Locales.include?(trans.locale)
          translation = record.translations.find_or_initialize_by(locale: trans.locale)
          translation.update_attributes!(trans.slice(fields).reject! { |k,v| v.nil?})
        end
      end
    end

    def manage_images(record,images)
      images.each do |image|
        record.images.find_by_id(image.id).destroy! if image._destroy.to_i == 1
      end
    end

    def manage_taglists(record,taglists)
      taglists.each do |taglist|
        tlist = record.taglists.find_by_id(taglist.id)
        if taglist._destroy.to_i == 1
          tlist.destroy! unless tlist.nil?
        else
          record.taglists.create!(taglist.slice(:tag_id)) unless taglist.tag_id.blank? || !tlist.blank?
        end
      end
    end

    def manage_self_associations(record,relationships)
      relationships.each do |rel|
        if record == rel.send("#{record.model_name.singular}1") || record == rel.send("#{record.model_name.singular}2")
          relation = record.send("related_#{record.model_name.singular}_relations").find_by_id(rel.id)
          if rel._destroy.to_i == 1
            relation.destroy! unless relation.nil?
          else
            unless rel.send("#{record.model_name.singular}1").blank? || rel.send("#{record.model_name.singular}2").blank?
              if rel.category.starts_with?('-')
                rel.assign_attributes("#{record.model_name.singular}1" => rel.send("#{record.model_name.singular}2"),
                                      "#{record.model_name.singular}2" => rel.send("#{record.model_name.singular}1"),
                                      category: rel.category[1..-1])
              end
              attributes = rel.slice("#{record.model_name.singular}1","#{record.model_name.singular}2",:category)
              if relation.nil?
                record.send("related_#{record.model_name.singular}_relations").create!(attributes)
              else
                relation.update_attributes!(attributes)
              end
              add_to_log(attributes["#{record.model_name.singular}1"])
              add_to_log(attributes["#{record.model_name.singular}2"])
            end
          end
        end
      end
    end

    def manage_association(record,join_records,joined_model,self_model)
      join_records.each do |rel|
        if record == rel.send(self_model)
          relation = record.send(rel.model_name.plural).find_by_id(rel.id)
          if rel._destroy.to_i == 1
            relation.destroy! unless relation.nil?
          else
            unless rel.send(joined_model).blank?
              if relation.nil?
                record.send(rel.model_name.plural).create!(rel.slice(joined_model,:category))
              else
                relation.update_attributes!(rel.slice(:category))
              end
              add_to_log(rel.send(joined_model))
              add_to_log(rel.send(self_model))
            end
          end
        end
      end
    end

    def upload_images(record,new_images)
      new_images.each do |image_info|
        image_info = {image: image_info} unless image_info.is_a?(Hash) #Converts simple images into a hash
        full_dir_path = "#{Rails.application.secrets.image_directory}/#{record.model_name.plural}/#{record.id}"
        Dir.mkdir(full_dir_path) unless File.exists?(full_dir_path)
        mini_image = MiniMagick::Image.read(image_info[:image].read)
        extension = mini_image.type.downcase
        extension = 'jpg' if extension == 'jpeg' #replace jpeg with jpg
        file_name = image_info[:image].original_filename.strip #with file extension
        file_name = file_name[0..-(mini_image.type.length + 2)] if file_name.downcase.ends_with?(mini_image.type.downcase)
        record_image_paths = record.images.map(&:path)
        original_name = file_name
        i = 1
        while record_image_paths.include?("#{record.model_name.plural}/#{record.id}/#{file_name}.#{extension}")
          file_name = original_name + " #{i}"
          i += 1
        end
        attributes = generate_attributes(record,image_info,file_name,extension)
        #Finally, create an image record and add the image to the instance.
        unless attributes[:name].blank? || attributes[:path].blank?
          mini_image.write(Rails.root.join(Rails.application.secrets.image_directory,attributes[:path]))
          record.images << Image.create(attributes)
        end
      end
    end

    def generate_attributes(record,image_info,file_name,extension)
      attributes_hash = {name: image_info[:image_name] || file_name } #defaults to file_name if not provided
      attributes_hash[:path] = "#{record.class.model_name.plural}/#{record.id}/#{file_name}.#{extension}"
      attributes_hash[:primary_flag] = image_info[:primary_flag] || (record.images.empty? ? 'Primary' : '')
      attributes_hash[:rating]  = 'NWS' unless image_info[:nws_flag].blank?
      return attributes_hash
    end

    def handle_date(att_model,field,date_hash)
      mask = 0
      attributes = date_hash.dup
      if att_model.has_attribute?(field) && att_model.has_attribute?("#{field}_bitmask")
        if date_hash.key?("#{field}(1i)") && date_hash.key?("#{field}(2i)") && date_hash.key?("#{field}(3i)")
          if date_hash["#{field}(1i)"].is_a?(String) && date_hash["#{field}(2i)"].is_a?(String) && date_hash["#{field}(3i)"].is_a?(String)
            if date_hash["#{field}(1i)"].empty? && date_hash["#{field}(2i)"].empty? && date_hash["#{field}(3i)"].empty?
              attributes["#{field}"] = nil
              attributes["#{field}_bitmask"] = nil
              attributes[field] = nil if date_hash.key?(field)
              attributes[field.to_sym] = nil if date_hash.key?(field.to_sym)
            else #handle normally
              attributes["#{field}(1i)"], mask = '1900', mask + 1 if date_hash["#{field}(1i)"].empty?
              attributes["#{field}(2i)"], mask = '1', mask + 2 if date_hash["#{field}(2i)"].empty?
              attributes["#{field}(3i)"], mask = '1', mask + 4 if date_hash["#{field}(3i)"].empty?
              attributes["#{field}_bitmask"] = mask if date_hash["#{field}_bitmask"].nil?
            end
            att_model.assign_attributes(attributes)
          end
        end
      end
    end

    def generate_date(record,field)
      date = record.send(field)
      bitmask = record.send("#{field}_bitmask") || 7
      ActiveSupport::HashWithIndifferentAccess.new({"#{field}(1i)" => (1 & bitmask).zero? ? date.year : '',
                                                    "#{field}(2i)" => (2 & bitmask).zero? ? date.month : '',
                                                    "#{field}(3i)" => (4 & bitmask).zero? ? date.day : ''})
    end

    def add_to_log(record)
      @log.loglists.create!(model: record) unless @log.nil? || @log.loglists.where(model: record).exists?
    end

end