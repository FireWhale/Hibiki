module FormattingModule

  def name_language_helper(record,user,priority)
    array = []
    if record.respond_to?(:namehash) && record.namehash.nil? == false && record.namehash.empty? == false
      if record.class.to_s == "Artist"
        languagesettings = user.artist_language_settings.split(",")
      else
        languagesettings = user.language_settings.split(",")
      end          
      languagesettings.each do |language|
        if record.namehash[language.to_sym].nil? == false && record.namehash[language.to_sym].empty? == false
          array.push(record.namehash[language.to_sym])
        end
      end   
    else
      array.push(record.name)
      if record.class.to_s != "Song" && record.class.to_s != "Tag" && record.altname.nil? == false
        if record.altname.empty? == false
          array.push(record.altname)
        end
      end
    end
    array[priority]
  end    
  
  def format_date_helper(field,values)  
    #Allows partial dates in the following fields:
    #Albums - releasedate
    #Artists - birthdate, debutdate
    #Organization - established
    #Source - releasedate
    #User - birthdate <--not yet implemented
    #Grab the date from values
    year = values[field + '(1i)']
    month = values[field + '(2i)']
    day = values[field + '(3i)']
    #search for related bitmask field. if it doesn't exist, return date
    if self.respond_to?(field + "_bitmask") && year.nil? == false && month.nil? == false && day.nil? == false
      unless year.empty? && month.empty? && day.empty?
        #If they are all empty, do nothing.
        bitmask = 0
        if year.empty?
          year = '1900'
          bitmask = bitmask + 1
        end
        if month.empty?
          month = '1'
          bitmask = bitmask + 2
        end
        if day.empty?
          day = '1'
          bitmask = bitmask + 4
        end        
        values[(field + '_bitmask').to_sym] = bitmask
        values[field + '(1i)'].replace year
        values[field + '(2i)'].replace month
        values[field + '(3i)'].replace day     
      end
    end 
  end

end
