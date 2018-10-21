class NeoQueryer
  include Performable

  def initialize(model,type, options={})
    @model = model
    @type = type
    @id = options[:id].to_i
    @limit = options[:limit] || 10
    @page = options[:page].to_i
  end


  def perform
    result = {}
    result[:query] = record_query(@model,@id,@page,@limit) if @type == 'record'
    result[:query] = model_query(@model,@page,@limit) if @type == 'model'
    result[:query] = info_query(@model,@id) if @type == 'info'
    result[:query] = count_query if @type == 'count'
    result[:nodes] = format_response(result[:query],@type) unless result[:query].nil?
    result[:paged] = paginate_results(result[:nodes],@page,@limit) unless result[:nodes].nil?
    return result
  end

  private
    def record_query(model,id,page,limit) #Used when expanding a node that has record info
      skip = page.nil? ? 0 :  (page - 1) * limit # Can probably put this into the first half of the query
      unless get_neo_record(model,id).nil?
        Neo4j::ActiveBase.current_session.query("MATCH (n:#{model})-[a]-(b)--(c) where n.uuid = {id}
                                          RETURN b,count(c) as count,type(a) ORDER BY count DESC
                                          UNION match (n:#{model})-[a]-(b) where n.uuid = {id} AND NOT (n:#{model})-[a]-(b)--()
                                          RETURN b,0 as count, type(a)",id: id)
      end
    end

    def model_query(model,page,limit) #Used when expanding a node with no record info
      skip = page.nil? ? 0 :  (page - 1) * limit
      if %w(Album Artist Organization Source Song Season Event Tag).include?(model)
        Neo4j::ActiveBase.current_session.query("MATCH (n:#{model})--(b) RETURN n,count(b) SKIP {skip} LIMIT {limit}", skip: skip, limit: limit)
      end
    end

    def count_query #used to get the count of all node labels
      Neo4j::ActiveBase.current_session.query("MATCH (n) RETURN DISTINCT labels(n), count(labels(n))")
    end

    def info_query(model,id) #used to
      if %w(Album Artist Organization Source Song Season Event Tag).include?(model)
        Neo4j::ActiveBase.current_session.query("MATCH (n:#{model})--(b) where n.uuid = {id} RETURN n,count(b)", id: id)
      end
    end

    def paginate_results(nodes,page,limit)
      Kaminari.paginate_array(nodes).page(page).per(limit)
    end

    def get_neo_record(model,id)
      if %w(Album Artist Organization Source Song Season Event Tag).include?(model)
        model.constantize.find_by_id(id)
      end
    end

    def format_response(query, type)
      records = []
      if %w(record model info).include?(type)
        query.rows.each do |row|
          props = row[0].props.reject! {|a| [:created_at,:updated_at].include?(a)}
          props[:label] = row[0].labels.first.to_s
          props[:count] = type == 'record' ? row[1] + 1 : row[1] # +1 to count for node a in record queries
          props[:type] = row[2] unless row[2].nil?
          records << props
        end
      elsif type == 'count'
        records = query.rows.select { |a| %w(Album Artist Organization Source Song Season Event Tag).include?(a[0][0]) }
                      .map { |a| [a[0][0], a[1]] }.sort
      end
      return records
    end
end