class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include ActionView::Helpers::TextHelper

  helper_method :current_user_session, :current_user, :language_helper, :watched?
  
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { render "pages/access_denied" }
      format.json { head :forbidden }
      format.js {head :forbidden }
    end
  end
  
  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.html { render "pages/record_not_found" }
      format.json { head :not_found }      
    end
  end
  
  #User methods!
  def language_helper(record, field, opts = {})
    #takes priority and highlight as opts
    if record.respond_to?("read_#{field}")
      value = record.send("read_#{field}", current_user)[(opts[:priority] ? opts[:priority] : 0)]
    else
      value = record.name
    end
    if opts[:highlight] == false || current_user.nil?
      value #Do not highlight
    else
      highlighter = "\\1"
      if [Artist, Organization, Source].include?(record.class) && record.watched?(current_user) && current_user.display_settings.include?("Bold AOS")
        highlighter = "<strong>#{highlighter}</strong>"
      end
      if current_user.abilities.include?("Admin") && current_user.display_settings.include?("Edit Mode") &&
        ((record.class == Album && record.tags.map(&:name).include?("Update Available")) || 
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
    record.send('related_' + record.class.to_s.downcase + '_relations').each do |relation|
      if relation.send(record.class.to_s.downcase + '1_id') == record.id && categories[relation.category].nil? == false
        if relation.category == "Same Song"
          #special case: Same song requires the album
          (relatedhash[categories[relation.category][0]] ||= []) << relation.send(record.class.to_s.downcase + '2').album   
        else
          (relatedhash[categories[relation.category][0]] ||= []) << relation.send(record.class.to_s.downcase + '2')    
        end
        if categories[relation.category[2]] == true && ids.nil? == false
          ids << relation.send(record.class.to_s.downcase + '2').id
        end
      elsif relation.send(record.class.to_s.downcase + '2_id') == record.id && categories[relation.category].nil? == false
        if relation.category == "Same Song"
          #special case: Same song requires the album
          (relatedhash[categories[relation.category][1]] ||= []) << relation.send(record.class.to_s.downcase + '1').album   
        else
          (relatedhash[categories[relation.category][1]] ||= []) << relation.send(record.class.to_s.downcase + '1')    
        end
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
end
