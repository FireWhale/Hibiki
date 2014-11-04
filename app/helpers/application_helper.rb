module ApplicationHelper

  #User Application methods
    
    def privacy_settings(user)
      privacyarray = User::PrivacySettings
      privacysettings = privacyarray.reject { |r| ((user.privacy.to_i || 0 ) & 2**privacyarray.index(r)).zero?}
    end
  
  #Image Methods
    #There are independent methods that stack together to form the complete image display:

    # image, size, title, path, collect/ignore outlines, and nws settings.
    #First we deal with formatting the link_to:
    def primary_image_helper(record, path, size, options = {})
      #Takes in a record and creates a link_to for the primary image 
      #Options:
      #    :class = Gives the link_to a class
      #       Class modifications:
      #       :border =   Gives a bootstrap border if set
      #       :outline_flag = Gives the link_to a class that will outline the album
      #       :margin = Gives the  image a margin on the bottom
      #       :square = Makes the image a square (via javascript lazyload)
      #    :album_list = Used for a slightly different Cover is not Available picture
      #    :nil_image = If there's no primary image, don't link anything. 
      #    :lazyload = If false, don't lazy load. lazyload passes through to image_helper
      if options[:class].nil? 
        options[:class] = 'thumbnail'
      end
      if current_user.nil? #Default is displayLEs and DisplayIgnored
        display_settings = ["DisplayLEs", "DisplayIgnored"]
      else
        display_settings = current_user.display_settings
      end
      if options[:border].nil? == false
        options[:class] = options[:class] + ' thumbnail-bordered'
      end
      if options[:margin].nil? == false
        options[:class] = options[:class] + ' thumbnail-margined'        
      end
      if options[:square].nil? == false
        options[:class] = options[:class] + ' thumbnail-square'                
      end
      if options[:outline_flag].nil? == false && record.class == Album && 
      display_settings.include?("AlbumArtOutline") && 
      record.collected_category(current_user).empty? == false 
        #Default is no flag. Otherwise, we'll outline the image if conditions are met
        options[:class] = options[:class] + ' ' + record.collection?(current_user).downcase
      end
      if record.primary_images[0].nil? 
        if record.class == Album
          #Use a slightly different no cover available picture
          link_to_if(options[:album_list].nil?, image_tag('no cover.jpg', :title => name_language_helper(record,current_user,0, :no_bold => true), :class => 'lazyload'), path, :class => options[:class]) do
            link_to(image_tag('cover not available.png', :title => name_language_helper(record,current_user,0, :no_bold => true), :class => 'lazyload'), path, :class => options[:class])            
          end
        else
          link_to_if(options[:nil_image].nil?, name_language_helper(record,current_user,0, :no_bold => true), path, :class => options[:class] + " text-center") do
            "<div class='text-center'>No Image available</div>".html_safe         
          end
        end
      else
        link_to image_helper(record.primary_images[0], size, :title => name_language_helper(record,current_user,0, :no_bold => true), :lazyload => (options[:lazyload] == false ? nil:true)), path, :class => options[:class]  
      end      
    end
        
    def image_helper(image, size, options = {}) 
      #passes in an Image Object, checks the image object for nws content.
      #returns an image_tag with the appropriate path.
      #Options:
      #    :title => sets the title of the image
      #    :lazyload => if false, uses old image_tag (aka x_image_tag)
      #    :show_nws => if present, ignore nws settings
      if current_user.nil?
        display_settings = ["DisplayLEs", "DisplayIgnored"]
      else
        display_settings = current_user.display_settings
      end      
      if image.rating == "NWS" && display_settings.include?("DisplayNWS") == false && options[:show_nws].nil? == true
        image_tag('not safe for yayois.png', :title => options[:title], :class => "lazyload")
      else  
        #Call for medium => looks for medium path. If no medium path, default to full, which should be smaller than medium.
        if size == 'medium' && image.medium_path.nil? == false && image.medium_path.empty? == false
          if options[:lazyload].nil?
            #Don't lazyload
            x_image_tag("/images/" + image.medium_path, :title => options[:title])
          else
            image_tag("/images/" + image.medium_path, :title => options[:title], :class => 'lazyload') 
          end       
        elsif size == 'thumb' && image.thumb_path.nil? == false && image.thumb_path.empty? == false
          if options[:lazyload].nil?
            #Don't lazyload
            x_image_tag("/images/" + image.thumb_path, :title => options[:title])            
          else
            image_tag("/images/" + image.thumb_path, :title => options[:title], :class => 'lazyload')
          end
        else
          if options[:lazyload].nil?
            #Don't lazyload
            x_image_tag("/images/" + image.path, :title => options[:title])
          else
            image_tag("/images/" + image.path, :title => options[:title], :class => 'lazyload')
          end
        end
      end
    end
    
  #These help format and display information on records
    def attribute_display(record, attribute, text)
      #this can display a record's attribute nicely and cleanly, along with description
      if record.send(attribute).nil? == false
        if record.send(attribute).instance_of?(String)
          if record.send(attribute).empty? == false
            (content_tag(:b) do
              if text.empty? == false
                text + ": "
              end
            end).concat(record.send(attribute)).concat(tag(:br)).html_safe        
          end
        elsif record.send(attribute).instance_of?(Date)
          (content_tag(:b) do
            if text.empty? == false
              text + ": "
            end
          end).concat(date_helper(record,attribute)).concat(tag(:br)).html_safe    
        else
          (content_tag(:b) do 
            if text.empty? == false
              text + ": "
            end
          end).concat(record.send(attribute)).concat(tag(:br)).html_safe
        end
      end
    end
    
    def linked_attribute_display(collection, text)
      if collection.empty? == false
        (content_tag(:b) do 
            if text.empty? == false
              text + ": "
            end
        end).concat(collection.map{ |wl| 
        if wl.class == Song
          link_to name_language_helper(wl,current_user,0), url_for(wl.album)
        elsif wl.class == Event
          link_to wl.shorthand, url_for(wl)
        else
          link_to name_language_helper(wl,current_user,0), url_for(wl)
        end }.join(', ').html_safe).concat(tag(:br)).html_safe
      end
    end
    
    def date_helper(record,attribute)
      #Used to format Release date and Birth Date
      if record.class == Album && attribute == 'releasedate'
        if record.releasedate_bitmask == 6
          link_to record.send(attribute).year, calendar_url(:date => record.send(attribute))
        elsif record.releasedate_bitmask == 4
          link_to record.send(attribute).to_formatted_s(:month_and_year), calendar_url(:date => record.send(attribute))
        else
          link_to record.send(attribute).to_formatted_s(:long), calendar_url(:date => record.send(attribute))
        end
      elsif record.respond_to?(attribute + "_bitmask")
        if record.send(attribute + '_bitmask') == 6
          record.send(attribute).year.to_s
        elsif record.send(attribute + '_bitmask') == 4
          record.send(attribute).to_formatted_s(:month_and_year)
        elsif record.send(attribute + '_bitmask') == 1
          record.send(attribute).to_formatted_s(:month_and_day)
        else
          record.send(attribute).to_formatted_s(:long)
        end
      else
        record.send(attribute).to_formatted_s(:long)
      end
    end
    
    def reference_helper(record)
      #Well this has a lot of tweaks to the reference symbols to make them presentatble to the public.
      if record.reference.nil? == false
        (content_tag(:b) do 
           "References: "
        end).concat(record.reference.map{|k,v| link_to k.to_s.gsub("_", " ").gsub("ppp", ".").split.map(&:camelize).join(' '), v}.join(' | ').html_safe).concat(tag(:br)).html_safe
      end
    end

  #Random Status helper lol
    def status_helper(record)
      #this checks both the status and db status of the record and returns information.
      if record.status == "Unreleased"
        (content_tag(:div) do
           "Warning! This " + record.class.to_s.camelize(:lower) + "'s info is incomplete"
        end).concat(tag(:br)).html_safe   
      elsif record.status == "Released"
        if record.db_status == "Up to Date"
          (content_tag(:div) do
            "This " + record.class.to_s.camelize(:lower) + " is up to date as of " + record.updated_at.to_date.to_s(:db)
          end).concat(tag(:br)).html_safe           
        elsif record.db_status == "Complete"
          (content_tag(:div) do
            "This " + record.class.to_s.camelize(:lower) + " has no more albums coming out! (" + record.updated_at.to_date.to_s(:db) + ")"
          end).concat(tag(:br)).html_safe
        elsif record.db_status == "Partial"      
          (content_tag(:div) do
            "This " + record.class.to_s.camelize(:lower) + " may be missing albums (" + record.updated_at.to_date.to_s(:db) + ")"
          end).concat(tag(:br)).html_safe
        elsif record.db_status == "Ignored"
          (content_tag(:div) do
            "This " + record.class.to_s.camelize(:lower) + " is ignored. sorry (" + record.updated_at.to_date.to_s(:db) + ")"
          end).concat(tag(:br)).html_safe                
        end  
      elsif record.status == ""
        (content_tag(:div) do
           "Dude you found one. Check out the status"
        end).concat(tag(:br)).html_safe             
      end
    end
  
end
