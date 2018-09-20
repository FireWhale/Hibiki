module ApplicationHelper

  #User Application methods
    
    def privacy_settings(user)
      privacyarray = User::PrivacySettings
      privacysettings = privacyarray.reject { |r| ((user.privacy.to_i || 0 ) & 2**privacyarray.index(r)).zero?}
    end
  
  #Image Methods
    #There are independent methods that stack together to form the complete image display:

    def primary_image_helper(record,path,size,options = {})
      image = record.primary_images.empty? ? nil : record.primary_images.first
      options[:model] ||= record.class.name
      options[:title] ||= language_helper(record, :name, highlight: false)
      if [Album, Song].include?(record.class)
        options[:collection] = record.collected_category(current_user).downcase
      end
      image_linker(image,path,size,options)
    end

    def image_linker(image,path,size,options = {}) #Adds an extra box to the image
      options[:class] ||= 'thumbnail'
      options[:class] += ' thumbnail-bordered' if options[:border]
      options[:class] += ' thumbnail-margined' if options[:margin]
      options[:class] += ' thumbnail-square' if options[:square]
      options[:class] += " #{options[:collection]}" if options[:highlight] && options[:collection].empty? == false
      image_tag = image_tag_builder(image,size,options)
      link_to_unless(image_tag.nil?,image_tag,path,options) do
        "<div class='text-center'>No Image available</div>".html_safe
      end
    end

    def image_tag_builder(image,size, options = {}) #Shows an image
      image_path = image_path_generator(image,size,options)
      data = {ratio: (image.width / image.height.to_f)} unless image.nil?
      unless image_path.empty?
        image_tag(image_path, title: options[:title], data: data)
      end
    end

    def image_path_generator(image, size, options = {}) #
      image_path = Rails.application.secrets.image_path
      display_settings = current_user.nil? ? [] : current_user.display_settings
      if image.nil?
        if ['Album','Song'].include?(options[:model])
          image_path += options[:album_list] ? 'assets/cover not available.png' : 'assets/no cover.jpg'
        else
          image_path = ''
        end
      elsif image.rating == 'NWS' && display_settings.include?("DisplayNWS") == false && options[:show_nws].nil?
        image_path += 'assets/not safe for yayois.png'
      else
        if size == 'medium' && image.medium_path.nil? == false && image.medium_path.empty? == false
          image_path += "/images/" + image.medium_path
        elsif size == 'thumb' && image.thumb_path.nil? == false && image.thumb_path.empty? == false
          image_path += "/images/" + image.thumb_path
        else
          image_path += "/images/" + image.path
        end
      end
      return image_path
    end

    def images_path_helper(record,image = nil, nws = false) #for linking to the albumart or images url
      params = "image: #{image.id}" unless image.nil?
      params += ", show_nws: true" if nws
      if record.class == Album
        eval("albumart_album_path(#{params})")
      else
        eval("images_#{record.class.name.downcase}_path(#{params})")
      end
    end

  #These help format and display information on records
    def attribute_display(record, attribute, text)
      #this can display a record's attribute nicely and cleanly, along with description
      unless record.send(attribute).nil?
        if record.send(attribute).instance_of?(String)
          unless record.send(attribute).empty?
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
      if record.respond_to?("#{attribute}_formatted")
        string = record.send("#{attribute}_formatted")
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
        end).concat(record.references.meets_role(current_user).map {|ref| link_to ref.site_name, ref.url}.join(' | ').html_safe).concat(tag(:br)).html_safe
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
          content_tag(:div, image_linker(record, images_path_helper(record.model,record),size, title: language_helper(record.model,:name), class: 'post-img'))
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
