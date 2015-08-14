json.set! title, helper_array do |grouping, records|
  json.set! grouping.downcase.tr(" ", "_"), records do |item|
    item.as_json(user: current_user, root: false).each { |k,v| json.set! k, v}
    json.url polymorphic_url(item, host: request.base_url)
  end
end