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
      unless options[:border].nil?
        options[:class] = options[:class] + ' thumbnail-bordered'
      end
      unless options[:margin].nil? 
        options[:class] = options[:class] + ' thumbnail-margined'        
      end
      unless options[:square].nil?
        options[:class] = options[:class] + ' thumbnail-square'                
      end
      if options[:outline_flag].nil? == false && record.class == Album && 
      display_settings.include?("AlbumArtOutline") && 
      record.collected_category(current_user).empty? == false 
        #Default is no flag. Otherwise, we'll outline the image if conditions are met
        options[:class] = options[:class] + ' ' + record.collected_category(current_user).downcase
      end
      if record.primary_images[0].nil? 
        if record.class == Album
          #Use a slightly different no cover available picture
          link_to_if(options[:album_list].nil?, image_tag('no cover.jpg', :title => language_helper(record, :name, highlight: false), lazy: true, class: 'lazyload'), path, :class => options[:class]) do
            link_to(image_tag('cover not available.png', :title => language_helper(record,:name, highlight: false), lazy: true, class: 'lazyload'), path, :class => options[:class])            
          end
        else
          link_to_if(options[:nil_image].nil?, language_helper(record,:name, highlight: false), path, :class => options[:class] + " text-center") do
            "<div class='text-center'>No Image available</div>".html_safe         
          end
        end
      else
        link_to image_helper(record.primary_images[0], size, :title => language_helper(record,:name, highlight: false), :lazyload => (options[:lazyload] == false ? nil:true)), path, :class => options[:class]  
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
      if image.rating == "NWS" && display_settings.include?("DisplayNWS") == false && options[:show_nws].nil?
        image_tag('not safe for yayois.png', :title => options[:title], lazy: true, :class => "lazyload")
      else  
        #Call for medium => looks for medium path. If no medium path, default to full, which should be smaller than medium.
        if size == 'medium' && image.medium_path.nil? == false && image.medium_path.empty? == false
          path = "/images/" + image.medium_path
        elsif size == 'thumb' && image.thumb_path.nil? == false && image.thumb_path.empty? == false
          path = "/images/" + image.thumb_path
        else
          path = "/images/" + image.path
        end
        #Lazy load the image
        if options[:lazyload].nil?
          image_tag(path, :title => options[:title], data: {ratio: (image.width / image.height.to_f)})
        else
          image_tag(path, :title => options[:title], data: {ratio: (image.width / image.height.to_f)}, lazy: true, class: 'lazyload')
        end
      end
    end
    
  #These help format and display information on records
    def attribute_display(record, attribute, text)
      #this can display a record's attribute nicely and cleanly, along with description
      unless record.send(attribute).nil?
        if record.send(attribute).instance_of?(String)
          if record.send(attribute).empty? == false
            (text.empty? ? "" : content_tag(:b, text + ": ")).concat(record.send(attribute)).concat(tag(:br)).html_safe        
          end
        elsif record.send(attribute).instance_of?(Date)
          (text.empty? ? "" : content_tag(:b, text + ": ")).concat(date_helper(record,attribute)).concat(tag(:br)).html_safe    
        else
          (text.empty? ? "" : content_tag(:b, text + ": ")).concat(record.send(attribute)).concat(tag(:br)).html_safe
        end
      end
    end
    
    def linked_attribute_display(collection, text)
      unless collection.empty?
        (text.empty? ? "" : content_tag(:b, text + ": ")).concat(collection.map{ |record| 
        if record.class == Song
          link_to language_helper(record,:name), url_for(record.album)
        elsif record.class == Event
          link_to record.name_helper("shorthand", "read_abbreviation", "read_name"), url_for(record)
        else
          link_to language_helper(record,:name), url_for(record)
        end }.join(', ').html_safe).concat(tag(:br)).html_safe
      end
    end
    
    def date_helper(record,attribute, options = {})
      if record.respond_to?("#{attribute}_bitmask") == false
        string = record.send(attribute).to_formatted_s(:long)
      elsif record.send(attribute + '_bitmask') == 6
        string = record.send(attribute).year.to_s
      elsif record.send(attribute + '_bitmask') == 4
        string = record.send(attribute).to_formatted_s(:month_and_year)
      elsif record.send(attribute + '_bitmask') == 1
        string = record.send(attribute).to_formatted_s(:month_and_day)
      else
        string = record.send(attribute).to_formatted_s(:long)
      end
      if attribute != 'release_date' || options[:calendar_link] == false 
        string
      else
        link_to string, calendar_url(:date => record.send(attribute))
      end
    end
    
    def reference_helper(record)
      #Well this has a lot of tweaks to the reference symbols to make them presentatble to the public.
      unless record.references.empty?
        (content_tag(:b) do 
           "References: "
        end).concat(record.references.meets_security(current_user).map {|ref| link_to ref.site_name, ref.url}.join(' | ').html_safe).concat(tag(:br)).html_safe
      end
    end

  #Form helpers
    def render_form(records, opts = {})
      records = records.target if records.respond_to?("target") && records.target.class == Array
      multi_flag = true if records.class == Array
      records = [records] unless records.class == Array  
      render "layouts/forms/form", records: records, url: opts[:url], form_prefix: opts[:form_prefix], fields: opts[:fields], multi_flag: multi_flag, submit_title: opts[:submit_title], no_submit_tag: opts[:no_submit_tag]
    end
  
    def fields_helper(record, opts = {})
      model = record.class.model_name.param_key
      fields = opts[:fields] || record.class::FormFields
      form_prefix = opts[:form_prefix] || (opts[:multi_flag] ? "#{model}[#{record.id}]" : model)
      render "layouts/forms/fields", form_prefix: form_prefix, record: record, fields: fields, model: model
    end

    def single_field_helper(opts, record, form_prefix)
      #Render a form based on the type
      if opts[:type] == "markup"
        output = "<#{opts[:tag_name]}".html_safe
        output = output + "id=#{record.id}" if opts[:add_id]
        output = output + ">".html_safe
        opts[:no_div] = true
      elsif opts[:type] == "well_hide"
        output = render :partial => 'layouts/forms/well_toggle', locals: {:div_id => record.id, :toggle_id => "Song#{record.id}Toggle"} 
        opts[:no_div] = true
      else
        output =  render "layouts/forms/fields/#{opts[:type]}", opts: opts, form_prefix: form_prefix, record: record
      end
      opts[:no_div] == true ? output : content_tag(:div, class: opts[:div_class], id: opts[:div_id]) {output}
    end

  #Post Helper - for parsing a post's content and replacing with hyperlinks and images     
    def post_content_helper(content, identifier, characters=99999)
      formatted_content = format_content(content, characters)
      render "posts/show_content", content: formatted_content, id: identifier
    end
    
    def format_content(content, characters)
      subbed_content = content.gsub(/<record=\"[a-zA-Z]*,\d*.*?\">/) { |text|
        info = text.split("\"")[1..(text.split("\"").count - 2)].join("\"").split(",")
        record = info[0].constantize.find_by_id(info[1])
        unless record.class == Image
          label = info[2].nil? ? language_helper(record,:name) : info[2]
          link_to(label, record)
        else
          size = info[2].nil? || ["thumb", "full", "medium"].include?(info[2]) == false ? "thumb" : info[2]
          if record.model.class == Album
            link = albumart_album_path(record.model.id, :image => record.id)
          else
            link = eval("images_#{record.model.class.to_s.downcase}_path(#{record.model.id}, :image => #{record.id})")
          end
          content_tag(:div, link_to(image_helper(record, size, :title => language_helper(record.model,:name)), link), class: "post-img")
        end
      }
      truncated_content = truncate_html( simple_format(subbed_content, nil), length: characters, separator: ' ', omission: '<span>...</span>')    
      (output ||= []) << truncated_content
      if truncated_content.end_with?("<span>...</span></p>")
        extra_content = truncate_html( simple_format(subbed_content, nil), length: 99999)
        extra_content.slice!(truncated_content[0..-21])
        output << extra_content.split("</p>", 2)
        output.flatten!
      elsif truncated_content.end_with?("<span>...</span></a></p>")
        extra_content = truncate_html( simple_format(subbed_content, nil), length: 99999)
        extra_content.slice!(truncated_content[0..-25])
        split_link = extra_content.split("</a>", 2)
        output << split_link[1].split("</p>", 2)
        output << split_link.first
        output.flatten!
        output.last
      end
      output
    end
end
