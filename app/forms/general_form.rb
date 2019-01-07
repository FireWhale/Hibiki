class GeneralForm
  include ActiveModel::Model

  attr_accessor :log
  attr_accessor :record


  validates :record, presence: true
  validate :record_check

  def save
    valid? && persist ? true :  (@log.add_to_content('error',errors.full_messages.join(','),'Unresolved',true) unless @log.blank?; false)
  end

  #def save! #unused method. Keep?
    #valid? && persist!
  #end

  #def persisted? #unused method. keep?
    #false
  #end

  def record_attributes=(attributes) #takes form attributes and attaches to form object on instantiation
    new_attribute_record = model.new(attributes)
    new_attribute_record.length = format_length(attributes['length']) if model == Song
    @attribute_record = new_attribute_record
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

  def source_organizations_attributes=(attributes)
    @source_organizations ||= []
    attributes.each do |k, source_org|
      @source_organizations.push(SourceOrganization.new(source_org))
    end
  end

  def album_events_attributes=(attributes)
    @album_events ||= []
    attributes.each do |k, album_event|
      record = AlbumEvent.new(album_event.except(:join_reference))
      record.event.references.new(album_event[:join_reference]) unless record.event.blank? || album_event[:join_reference].blank?
      @album_events.push(record)
    end
  end

  def artist_albums_attributes=(attributes)
    @artist_albums ||= []
    attributes.each do |k, artist_album|
      record = ArtistAlbum.new(artist_album.except(:category,:translation,:join_reference)) #Except url for artist
      record.category = Artist.get_bitmask(artist_album[:category])
      record.translations.push(ArtistAlbum::Translation.new(artist_album[:translation])) unless artist_album[:translation].blank?
      record.artist.references.new(artist_album[:join_reference]) unless record.artist.blank? || artist_album[:join_reference].blank?
      @artist_albums.push(record)
    end
  end

  def artist_songs_attributes=(attributes)
    @artist_songs ||= []
    attributes.each do |k, artist_song|
      record = ArtistSong.new(artist_song.except(:category,:translation)) #Except url for artist
      record.category = Artist.get_bitmask(artist_song[:category])
      record.translations.push(ArtistSong::Translation.new(artist_song[:translation])) unless artist_song[:translation].blank?
      @artist_songs.push(record)
    end
  end

  def album_sources_attributes=(attributes)
    @album_sources ||= []
    attributes.each do |k, album_source|
      record = AlbumSource.new(album_source.except(:join_reference))
      record.source.references.new(album_source[:join_reference]) unless record.source.blank? || album_source[:join_reference].blank?
      @album_sources.push(record)
    end
  end

  def song_sources_attributes=(attributes)
    @song_sources ||= []
    attributes.each do |k, song_source|
      @song_sources.push(SongSource.new(song_source))
    end
  end

  def album_organizations_attributes=(attributes)
    @album_organizations ||= []
    attributes.each do |k, album_organization|
      record = AlbumOrganization.new(album_organization.except(:join_reference))
      record.organization.references.new(album_organization[:join_reference]) unless record.organization.blank? || album_organization[:join_reference].blank?
      @album_organizations.push(record)
    end
  end

  def self.reflect_on_association(klass) #For adding new records javascript
    data = { klass: klass }
    OpenStruct.new data
  end

  private
    def persist
      ActiveRecord::Base.transaction(requires_new: true) do
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
        if record == rel.send(self_model) #Make sure join_record is in model
          relation = record.send(rel.model_name.plural).find_by_id(rel.id) #finds existing record
          if rel._destroy.to_i == 1
            relation.destroy! unless relation.nil?
          else
            unless rel.send(joined_model).blank? #makes sure attaching record exists
              if relation.nil?
                relation = record.send(rel.model_name.plural).create!(rel.slice([joined_model,:category].select {|k| rel.respond_to?(k)}))
              else
                relation.update_attributes!(rel.slice([:category].select {|k| rel.respond_to?(k)}))
              end
              if self_model == 'album' && %(event source organization).include?(joined_model) #allow adding urls
                rel.send(joined_model).references.select { |ref| ref.new_record? }.each do |ref|
                  relation.send(joined_model).references.find_or_create_by!(ref.slice(:site_name, :url))
                end
              end
              if self_model== 'song' && joined_model == 'source' && !record.album.blank?
                record.album.album_sources.create!(source_id: rel.source_id)  unless record.album.sources.pluck(:id).include?(rel.source_id)
              end
              add_to_log(rel.send(joined_model))
              add_to_log(rel.send(self_model))
            end
          end
        end
      end
    end

    def manage_artist_association(record,join_records,self_model)
      join_records.each do |rel|
        if record == rel.send(self_model)
          relation = record.send(rel.model_name.plural).find_by_id(rel.id)
          if rel.category == '0'
            relation.destroy! unless relation.nil?
          else
            unless rel.artist.blank?
              if relation.nil?
                relation = record.send(rel.model_name.plural).create!(rel.slice([:artist,:category].select {|k| rel.respond_to?(k)}))
              else
                relation.update_attributes!(rel.slice([:category].select {|k| rel.respond_to?(k)}))
              end
              rel.translations.each{ |trans| relation.translations.create!(trans.slice(:locale,:display_name)) }
              if self_model == 'album' #allow adding urls
                rel.artist.references.select { |ref| ref.new_record? }.each do |ref|
                  relation.artist.references.find_or_create_by!(ref.slice(:site_name, :url))
                end
              end
              if self_model == 'song' && !record.album.blank? #Add information to album if present
                artist_album = record.album.artist_albums.find_by_artist_id(rel.artist_id)
                if artist_album.nil? #create
                  new_rel = record.album.artist_albums.create!(rel.slice(:artist, :category))
                  rel.translations.each { |trans| new_rel.translations.create!(trans.slice(:locale,:display_name)) }
                else
                  artist_album.update_attributes!(category: artist_album.category.to_i | rel.category.to_i)
                  #don't add translations if it already exists
                end
              end
              add_to_log(rel.artist)
              add_to_log(rel.send(self_model))
            end
          end
        end
      end
    end

    def upload_images(record,new_images) #This occurs outside of the transaction, afterward.
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

  #validation
  def record_check #Make sure record_attributes id (can be modified by user) matches passed_in_record's id (cannot be modified)
    unless @record.id == @attribute_record.id && @record.class == @attribute_record.class
      errors.add(:record, 'is different than attribute_record')
    end
  end

end