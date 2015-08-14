json.set! defined?(list_name) ? list_name : records.name.downcase.pluralize, records do |record|
  record.as_json(user: current_user, root: false).each { |k,v| json.set! k, v }
  json.url polymorphic_url(record, host: request.base_url)
end
