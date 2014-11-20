class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include ActionView::Helpers::TextHelper

  helper_method :current_user_session, :current_user, :name_language_helper, :watched?
  
  rescue_from CanCan::AccessDenied do |exception|
    render "pages/access_denied" 
  end
  
  rescue_from ActiveRecord::RecordNotFound do |exception|
    render "pages/record_not_found"
  end
      
  def filter_albums(collection)
    #This filters out reprints and alternate prints
    newcollection = []
    collection.map {|relationship|  
      #Filter out alternate printings
      if current_user.nil? 
        newcollection << relationship
      else
        if current_user.display_settings.include?("DisplayLEs")
          newcollection << relationship
        else
          if relationship.album.limited_edition? == false &&
            #and reprints/alternate printings
            relationship.album.reprint? == false && relationship.album.alternate_printing? == false
            #put it into a new collection array
            newcollection << relationship
          end     
        end   
      end
      }  
    newcollection   
  end
  
  #User methods!
    def name_language_helper(record,user,priority, opts = {})
      #options: no_bold: true  
      array = []
      if record.respond_to?(:namehash) && record.namehash.nil? == false && record.namehash.empty? == false
        if user.nil? #Guest users will be nil
          languagesettings = User::DefaultLanguages.split(",")
        else
          if record.class.to_s == "Artist" || record.class.to_s == 'Organization'
            languagesettings = user.artist_language_settings.split(",")
          else
            languagesettings = user.language_settings.split(",")
          end  
        end
        languagesettings.each do |language|
          unless record.namehash[language.to_sym].nil? || record.namehash[language.to_sym].empty?
            array.push(record.namehash[language.to_sym])
          end
        end   
      else
        array.push(record.name)
        if record.respond_to?(:altname) && record.altname.nil? == false
          if record.altname.empty? == false
            array.push(record.altname)
          end
        end
      end
      #If the priority specificed isn't available, we return nil
      if array[priority].nil?
        return nil
      end
      #Now we get the correct name of the record. 
      if opts[:no_bold].nil? == false || user.nil? || ["Album","Artist","Organization","Source"].include?(record.class.to_s) == false 
        #I'm not sure why I listed out all these cases where it's not the case.
        #It's kind of backwards, but it's how I developed it and it's a good footnote. 
        #If: no bold is present
        #If: no user is logged in
        #If: record is not an artist/org/source
        array[priority]        
      elsif ["Artist","Organization","Source"].include?(record.class.to_s) && record.watched?(user) && user.display_settings.include?("Bolding")
        if user.security == 'Admin' && record.status == 'Released' && user.display_settings.include?("EditMode")
          highlight(array[priority], array[priority], :highlighter => '<em><strong>\1</strong></em>')
        else
          highlight(array[priority], array[priority], :highlighter => '<strong>\1</strong>')
        end
      elsif user.security == 'Admin' && record.status == 'Released' && user.display_settings.include?("EditMode") && ["Artist","Organization","Source"].include?(record.class.to_s)
        highlight(array[priority], array[priority], :highlighter => '<em>\1</em>')        
      elsif user.security == 'Admin' && user.display_settings.include?("EditMode") && record.class.to_s == 'Album' && record.private_info.starts_with?('UPDATE AVAILABLE')
        highlight(array[priority], array[priority], :highlighter => '<em>\1</em>')  
      else
        #If nothing catches, it goes here!
        array[priority]
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
      @current_user = current_user_session && current_user_session.user
    end
end
