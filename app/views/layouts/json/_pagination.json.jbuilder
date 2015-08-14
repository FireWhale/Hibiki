json.set! defined?(pagination_name) ? pagination_name : :pagination do
  param_name = defined?(pagination_param_name) ? pagination_param_name : 'page'
  page = Kaminari::Helpers::Page.new self, {current_page: records.current_page, param_name: param_name }
  
  json.current_page records.current_page
  json.pages records.total_pages
  json.per_page records.limit_value
  json.items records.total_count
  json.urls do
    json.next request.base_url + page.page_url_for(records.current_page + 1) unless records.last_page?
    json.previous request.base_url + page.page_url_for(records.current_page - 1) unless records.first_page?
  end
end
