json_hash = record.as_json(user: current_user)

json.set! json_hash.keys[0] do
  json_hash.values[0].each { |k,v| json.set! k, v }
  
  #Omitting Source Organizations for now.
  
  if [Album, Artist, Organization, Source, Song].include?(record.class)
    if @fields.blank? || @fields.include?("related_#{record.class.to_s.downcase}s")
      json.partial! 'layouts/json/list_from_helper', locals: {helper_array: @related, title: "related_#{record.class.to_s.downcase}s"} unless @related.blank?
    end
  end
  
  if record.class == Album
    if @fields.blank? || @fields.include?('songs') || @fields.include?('full_song_info')
      if @fields.include?('full_song_info')
        json.songs record.songs do |song|
         json.partial! 'layouts/json/show', locals: {record: song}      
        end
      else
        json.songs record.songs.as_json(user: current_user, root: false)
      end
      
      #Added to as_json method. Seems pretty fundamental to album attributes. 
      #json.song_info do
        #json.total_songs self.songs.count
        #disc_count = self.songs.map(&:disc_number).uniq.max
        #json.total_discs = disc_count unless disc_count.nil?
      #end
    end
    if @fields.blank? || @fields.include?('events')
      json.partial! 'layouts/json/list_with_urls', locals: {records: record.events} unless record.events.empty?
    end      
    if @fields.blank? || @fields.include?('artists')
      json.partial! 'layouts/json/list_from_helper', locals: {helper_array: @credits, title: "artists"} unless @credits.blank?
    end
    if @fields.blank? || @fields.include?('organizations')
      json.partial! 'layouts/json/list_from_helper', locals: {helper_array: @organizations, title: "organizations"} unless @organizations.blank?
    end
    if @fields.blank? || @fields.include?('sources')
      json.partial! 'layouts/json/list_with_urls', locals: {records: record.sources} unless record.sources.empty?
    end
  end
  
  if record.class == Song
    if @fields.blank? || @fields.include?('artists')
      json.partial! 'layouts/json/list_from_helper', locals: {helper_array: @credits, title: "artists"} unless @credits.blank?
    end
    
    if @fields.blank? || @fields.include?('sources')
      json.sources record.song_sources.each do |song_source|
        json.op_ed song_source.classification unless song_source.classification.blank?
        json.op_ed_number song_source.op_ed_number unless song_source.op_ed_number.blank?
        json.episode_numbers song_source.ep_numbers unless song_source.ep_numbers.blank?
        json.source song_source.source.as_json(user: current_user, root: false).merge({url: polymorphic_url(song_source.source, host: request.base_url)})
      end
    end
  end
  
  if [Organization].include?(record.class) && record.artists.empty? == false
    if @fields.blank? || @fields.include?('artists')
      json.artists record.artist_organizations do |artist_organization|
        json.artist_relationship artist_organization.category
        json.artist artist_organization.artist.as_json(user: current_user, root: false).merge({url: polymorphic_url(artist_organization.artist, host: request.base_url)})
      end
    end
  end
  
  if [Artist, Source, Organization, Event].include?(record.class)
    if @fields.blank? || @fields.include?('albums')
      json.partial! 'layouts/json/pagination', locals: {records: @albums, pagination_name: "album_pagination", pagination_param_name: "album_page"}
      
      json.albums @albums do |album|
        json.artist_credits Artist.get_credits(album.artist_albums.where(artist_id: record.id)[0].category) if record.class == Artist
        json.organization_role album.album_organizations.where(organization_id: record.id)[0].category if record.class == Organization
        json.album album.as_json(user: current_user, root: false).merge({url: polymorphic_url(album, host: request.base_url)})
      end
    end
  end
  
  if [Album, Artist, Organization, Source, Song, Post].include?(record.class)
    if @fields.blank? || @fields.include?('tags')
      json.partial! 'layouts/json/list_with_urls', locals: {records: record.tags.meets_role(current_user)} unless record.tags.meets_role(current_user).empty?
    end
  end
  
  if [Album, Artist, Organization, Source, Song].include?(record.class)
    if @fields.blank? || @fields.include?('images')
      json.images record.images.as_json(user: current_user, root: false) unless record.images.empty?
    end
    if @fields.blank? || @fields.include?('posts')
      json.partial! 'layouts/json/list_with_urls', locals: {records: record.posts.meets_role(current_user)} unless record.posts.meets_role(current_user).empty?
    end
  end
  
  if record.class == Season
    if @fields.blank? || @fields.include?('sources')
      json.partial! 'layouts/json/list_from_helper', locals: {helper_array: @sources, title: "sources"} unless @sources.blank?
    end
  end
  
  if record.class == Image
    json.records record.models do |model|
      json.set! model.as_json.keys[0], model.as_json(user: current_user).values[0].merge({url: polymorphic_url(model, host: request.base_url)})
    end
  end
  
  if record.class == Tag
    if @fields.blank? || @fields.include?('records')    
      json.partial! 'layouts/json/pagination', locals: {records: @records, pagination_name: "record_pagination", pagination_param_name: "record_page"}         
      json.records @records do |record|
        json.set! record.class.to_s.downcase do
          record.as_json(user: current_user, root: false).merge({url: polymorphic_url(record, host: request.base_url)}).each { |k,v| json.set! k, v }
        end
      end
    end
  end
  
end
