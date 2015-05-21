RSpec::Matchers.define :match_json_schema do |schema|
  match do |json_obj|
    schema_directory = "#{Dir.pwd}/spec/support/api/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, json_obj, strict: true)
  end
end