module RelationsModule
  
  def full_create(values)
    #This method will call the full_update_atributes method for whatever record it's called on.
    if self.save
      #If the required info is correct, the save will go through and we can call full_update
      self.full_update_attributes(values)
    end
  end
  
  def create_self_relation(identifiers,categories,model)
    #This method is used to create a relation between two records of the same model.
    #This method is used for Albums, Artists, Organizations, Sources, and Songs.
    #This can only be used on a instance of the class.
    #EX: record.create_self_relation(blahblahblah)
    relatedmodels = identifiers.zip(categories)
    relatedmodels.each do |each|
      if each[0].empty? == false
        exists = model.constantize.find_by_id(each[0])
        # if model == "Song" || model == "Album" || model == "Artist" || model == "Source"
        # #Does not create a song or album if not found.
        # else #Used to be for Artists, Organizations, Sources. 
          # #Creates the artist/organization/source if not found. 
          # #This is now obsolete code since all the models use IDs for identification.
          # exists = model.constantize.find_by_name(each[0])
          # if exists.nil?
            # exists = model.constantize.new(:name => each[0], :status => 'Unreleased')
            # exists.save
          # end
        # end
        if exists.nil? == false
          if each[1].starts_with?("-")
            each[1].slice!(0)
            self.send("related_" + model.downcase + "_relations2").create((model.downcase + "1_id").to_sym => exists.id, :category => each[1])
          else
            self.send("related_" + model.downcase + "_relations1").create((model.downcase + "2_id").to_sym => exists.id, :category => each[1])          
          end
        end
      end
    end  
  end

  def update_related_model(keys,values,model)
    #While this is an instance method, it really doesn't matter what instance you call it on.
    #The entire logic is performed within the model.
    #I'm really just too lazy to learn how to make this a class method instead of an instance method.
    if keys.class != Array
      keys = [keys]
    end
    if values.class != Array
      values = [values]
    end
    updates = keys.zip(values)
    updates.each do |relation|
      if relation[1][:category].starts_with?("-")
        relatedmodel = ("Related" + model + "s").constantize.find_by_id(relation[0])
        relation[1][model.downcase + '1_id'] = relatedmodel.send(model.downcase + "2_id")
        relation[1][model.downcase + '2_id'] = relatedmodel.send(model.downcase + "1_id")
        relation[1]['category'].slice!(0) #takes off the "-" 
      end
      ("Related" + model + "s").constantize.update(relation[0], relation[1])
    end
  end
  
  def delete_related_model(idarray,model)
    #Same concerns as update_related_model
    idarray.each do |each|
      ("Related" + model + "s").constantize.find(each).delete
    end
  end

end
