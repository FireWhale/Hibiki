module NeoRelModule
  extend ActiveSupport::Concern

  #Instance Methods

  def neo_model
    "Neo::#{self.class.name}".constantize
  end

  def neo_rel(from,to)
    neo_to = to.neo_db_record
    neo_from = from.neo_db_record
    #if neo_from.nil? || neo_to.neo_db_record.nil?
    #  Raise Exception
    #else
      rel = self.neo_model.new(from_node: neo_from, to_node: neo_to)
    #end
    return rel
  end

  def neo_db_rel(from,to)

  end

  private
    def neo_update

    end

    def neo_rel_update
      associations = self.class.reflections.keys.map { |rel| rel.gsub(/[12]$/,'')}.uniq.
          select {|f| f.include?("_")}.
          reject {|f|  f == "primary_images"}.
          reject {|f| f.include?("related_") && f.include?("_relations") == false}
      associations.each do |rel_name|
        opposing_model = rel_name.singularize.gsub(self.class.name.downcase,"").gsub("_","")
        self.send(rel_name).each do |relation|
          properties = {id: relation.id}
          neo_record = relation.send(opposing_model).neo_record
          unless neo_record.new_record?
            self.neo_record.send(opposing_model.pluralize).create(neo_record, properties) unless self.neo_record.send(opposing_model.pluralize).include?(neo_record)
          end

        end
      end

    end

end

