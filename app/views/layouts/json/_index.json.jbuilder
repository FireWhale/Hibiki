json.partial! 'layouts/json/pagination', locals: {records: records} if records.respond_to?(:current_page)

json.partial! 'layouts/json/list_with_urls', locals: {records: records}