class PrimaryRecordCounter
  include Performable

  def initialize(query_type,options = {})
    @type = query_type
    @model = options[:model]
    @current_user = options[:current_user]
    @query = options[:query]
    @col_user = options[:user]
    @col_category = options[:collection_category]
  end

  def perform
    return index_count(@model) if @type == 'index'
    return search_count(@model,@query,@current_user) if @type == 'search'
    return collection_count(@col_user,@col_category) if @type == 'collection'
  end

  private
    def search_count(model,query, current_user)
      model.capitalize.constantize.search do
        any do
          fulltext query do
            fields(:internal_name, :synonyms, :namehash, :translated_names, :references)
            fields(:catalog_number) if model == 'album'
            fields(:hidden_references) if current_user.nil? == false && current_user.abilities.include?('Confident')
          end
          if query.include?("*") || query.include?("?")
            fulltext "\"#{query}\"" do
              fields(:internal_name, :synonyms, :namehash, :translated_names, :references)
              fields(:catalog_number) if model == 'album'
              fields(:hidden_references) if current_user.nil? == false && current_user.abilities.include?('Confident')
            end
          end
        end
      end.total
    end

    def collection_count(user, col_cat)
      album_count = Album.in_collection(user.id, [col_cat]).count
      song_count = Song.in_collection(user.id, [col_cat]).count
      album_count + song_count
    end

    def index_count(model)
      model.count
    end
end