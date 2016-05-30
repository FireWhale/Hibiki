class ApplicationController < ActionController::Base
  protect_from_forgery

  include ActionView::Helpers::TextHelper

  helper_method :current_user_session, :current_user, :language_helper, :watched?

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      if current_user.nil? == false && current_user.status == "Deactivated"
        format.html { render "pages/deactivated" }
        format.json { head :forbidden }
        format.js {head :forbidden }
      else
        format.html { render "pages/access_denied" }
        format.json { head :forbidden }
        format.js {head :forbidden }
      end
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.html { render "pages/record_not_found" }
      format.json { head :not_found }
    end
  end

  def handle_partial_date_assignment(params,model)
    unless params.blank?
      date_fields = model.attribute_names.select { |i| i.ends_with?("bitmask")}.map { |i| i.chomp("_bitmask") }
      date_fields.each do |field|
        date_conversion(params,field) #do the first level first.
        params.each do |k,v|
          if v.is_a?(Hash)
            date_conversion(params[k],field)
            handle_partial_date_assignment(v,model)
          end
        end
      end
    end
    return params
  end

  def handle_length_assignment(params)
    unless params.blank?
      params.each do |k,v|
        if k == "length"
          if v.is_a?(String)
            params[k] = length_conversion(v)
          elsif v.is_a?(Array)
            params[k] = v.map { |i| length_conversion(i) }
          end
        elsif v.is_a?(Hash)
          handle_length_assignment(v)
        end
      end
    end

    return params
  end

  def language_helper(record, field, opts = {})
    #takes priority and highlight as opts
    if record.respond_to?("read_#{field}")
      value = record.send("read_#{field}", current_user)[(opts[:priority] ? opts[:priority] : 0)]
    else
      value = record.send(field)
    end
    if opts[:highlight] == false || current_user.nil? || [Album, Organization, Source, Artist].include?(record.class) == false
      value #Do not highlight
    else
      highlighter = "\\1"
      if [Artist, Organization, Source].include?(record.class) && record.watched?(current_user) && current_user.display_settings.include?("Bold AOS")
        highlighter = "<strong>#{highlighter}</strong>"
      end
      if current_user.abilities.include?("Admin") && current_user.display_settings.include?("Edit Mode") &&
        ((record.class == Album && record.tags.pluck(&:name).include?("Update Available")) ||
        ([Artist, Organization, Source].include?(record.class) && record.status == "Released"))
        highlighter = "<em>#{highlighter}</em>"
      end
      highlight(value, value, :highlighter => highlighter)
    end
  end

  def self_relation_helper(record,relatedhash,ids=nil)
    #This method prepares a @related hash with all of the self_relations of a record
    #First, prepare a hash that "translates" the data
    categories = {}
    record.class.const_get("SelfRelationships").reject {|type| type.count == 2}.each do |each|
      categories[each.last] = [each[1], each[2]]
    end
    #Next, loop over each of the relations and add it to the relatedhash
    record.send("related_#{record.class.to_s.downcase}_relations").each do |relation|
      if relation.send(record.class.to_s.downcase + '1_id') == record.id && categories[relation.category].nil? == false
        (relatedhash[categories[relation.category][0]] ||= []) << relation.send(record.class.to_s.downcase + '2')
        if categories[relation.category[2]] == true && ids.nil? == false
          ids << relation.send(record.class.to_s.downcase + '2').id
        end
      elsif relation.send(record.class.to_s.downcase + '2_id') == record.id && categories[relation.category].nil? == false
        (relatedhash[categories[relation.category][1]] ||= []) << relation.send(record.class.to_s.downcase + '1')
        if categories[relation.category[3]] == true && ids.nil? == false
          ids << relation.send(record.class.to_s.downcase + '1').id
        end
      end
    end
  end

  private
    def credits_helper(record,credits)
      record.send('artist_' + record.class.to_s.downcase + 's').each do |relation|
        Artist.get_credits(relation.category).each do |category|
          (credits[Artist::CreditsFull[category]] ||= []) << relation.artist
        end
      end
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end

    def length_conversion(string) #for use in handle_length_assignment
      unless string.blank?
        if string.include?(":") && string.count(":") == 1
          output = string.split(":")[0].to_i * 60 + string.split(":")[1].to_i
        elsif string.to_i.to_s == string.sub(/^[0]+/,"") #Leading zero removal
          output = string.to_i
        else
          output = nil
        end
      end
    end

    def date_conversion(params,field)
      mask = 0
      if params.key?("#{field}(1i)") && params.key?("#{field}(2i)") && params.key?("#{field}(3i)")
        if params["#{field}(1i)"].is_a?(String) && params["#{field}(2i)"].is_a?(String) && params["#{field}(3i)"].is_a?(String)
          if params["#{field}(1i)"].empty? && params["#{field}(2i)"].empty? && params["#{field}(3i)"].empty?
            params["#{field}"] = nil
            params["#{field}_bitmask"] = nil
            params[field] = nil if params.key?(field)
            params[field.to_sym] = nil if params.key?(field.to_sym)
          else #handle normally
            params["#{field}(1i)"], mask = '1900', mask + 1 if params["#{field}(1i)"].empty?
            params["#{field}(2i)"], mask = '1', mask + 2 if params["#{field}(2i)"].empty?
            params["#{field}(3i)"], mask = '1', mask + 4 if params["#{field}(3i)"].empty?
            params["#{field}_bitmask"] = mask if params["#{field}_bitmask"].nil?
          end
        elsif params["#{field}(1i)"].is_a?(Array) && params["#{field}(2i)"].is_a?(Array) && params["#{field}(3i)"].is_a?(Array)
          #Occurs when adding songs via album edit.
          mask_array = Array.new(params["#{field}(1i)"].length,0)
          [params["#{field}(1i)"],params["#{field}(2i)"],params["#{field}(3i)"]].each_with_index do |array_param,n|
            array_param.each_with_index do |value,m|
              if value.empty?
                if n == 0
                  array_param[m] = "1900"
                else
                  array_param[m] = "1"
                end
                mask_array[m] = mask_array[m] + 2**n
              end
            end
          end
          params["#{field}_bitmask"] = mask_array if params["#{field}_bitmask"].nil?
        end
      elsif params.key?(field) #If actual field is passed in as a date
        params["#{field}_bitmask"] = 0
      end
    end
end
