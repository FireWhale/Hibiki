json.partial! 'layouts/json/pagination', locals: {records: @records} if @records.respond_to?(:current_page)

json.results @records do |record|
  json.set! record.class.to_s.downcase do
    record.as_json(user: current_user, root: false).merge({url: polymorphic_url(record, host: request.base_url)}).each { |k,v| json.set! k, v }
  end
end