class PrimaryRecordGetter
  include Performable

  def initialize(query_type,options = {})
    @type = query_type
    @model = options[:model]
    @query = options[:query]
    @current_user = options[:current_user]
    @col_user = options[:user]
    @col_category = options[:collection_category]
    @page = options[:page]
  end

  def perform
    return index_query(@model,@page) if @type == 'index'
    return search_query(@model,@query,@page,@current_user) if @type == 'search'
    return collection_query(@col_user,@col_category,@page) if @type == 'collection'
  end

  private
    def generate_eager_loading(model)
      eager_hash = [:tags, :translations]
      eager_hash.push(:watchlists) if %w(artist organization source).include?(model)
      eager_hash.push(album: [:primary_images, :translations]) if model == 'song'
      eager_hash.push(:primary_images) if model == 'album'
      return eager_hash
    end

    def search_query(model,query,page,current_user)
      model.capitalize.constantize.search(:include => generate_eager_loading(model)) do
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
        order_by(:release_date) if model == 'album'
        paginate :page => page
      end
    end

    def collection_query(user, col_cat, page)
      albums = Album.in_collection(user.id, [col_cat]).includes(generate_eager_loading('album'))
      songs = Song.in_collection(user.id, [col_cat]).includes(generate_eager_loading('song'))
      records = (albums + songs).sort_by {|a| a.release_date ? a.release_date : Date.new }.reverse!
      Kaminari.paginate_array(records).page(page).per(30)
    end

    def index_query(model,page)
      order = nil #if song
      order = :release_date if model == 'album'
      order = :internal_name if %w(artist organization source).include?(model)
      model.capitalize.constantize.order(order).includes(generate_eager_loading(model)).page(page)
    end

end