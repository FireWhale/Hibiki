require 'rails_helper'

module StrongParametersTests

  shared_examples 'uses strong parameters' do |options = {}|
    model_class = described_class.controller_name.classify.constantize
    model_symbol = model_class.model_name.param_key.to_sym
    model_param_class = described_class.const_get("#{described_class.controller_name.classify}Params")

    #Format and grab params
    valid_params = options[:valid_params] || []
    invalid_params = options[:invalid_params] || []
    filter_method = options[:filter_method] || "filter"
    base_key = options[:base_key] == "none" ? nil : options[:base_key] || model_symbol  #If there's a root key added to final hash or not

    if filter_method == "filter"
      #Add all unlisted attributes as invalid
      invalid_params = (invalid_params + (model_class.attribute_names - valid_params)).uniq
      if model_class.attribute_names.include?("namehash")
        invalid_params = invalid_params - ["namehash"]
        invalid_params << {"namehash" => "string"} if valid_params.select {|a| a.is_a?(Hash) ?  a.key?("namehash") : false }.empty?
      end

      #Add Translated Field Automatically as invalid
      if model_class.included_modules.include?(LanguageModule)
        model_class.translated_attribute_names.each do |attribute|
          invalid_params << {"#{attribute}_langs" => "string"} if valid_params.select {|a| a.is_a?(Hash) ?  a.key?("#{attribute}_langs") : false }.empty?
          invalid_params << ["new_#{attribute}_langs"] unless valid_params.include?(["new_#{attribute}_langs"])
          invalid_params << ["new_#{attribute}_lang_categories"]unless valid_params.include?(["new_#{attribute}_lang_categories"])
        end
      end

      #Add Image Fields Automatically as invalid
      if model_class.included_modules.include?(ImageModule)
        invalid_params << ["new_images"] unless valid_params.include?(["new_images"])
        invalid_params << ["image_paths"] #Shouldn't ever be valid, since it's used in scraping
        invalid_params << ["image_names"] #Shouldn't ever be valid, since it's used in scraping
      end

      #Add Reference Fields Automatically as invalid
      if model_class.included_modules.include?(ReferenceModule)
        invalid_params << {"new_references" => {"site_names" => ["haha site_name"], "urls" => ["url"]}} if valid_params.select {|a| a.is_a?(Hash) ?  a.key?("new_references") : false }.empty?
        invalid_params << {"update_references" => {"5" => {"site_name" => "VGname", "url" => "VGurl"}}} if valid_params.select {|a| a.is_a?(Hash) ?  a.key?("update_references") : false }.empty?
      end

      #Add SelfRelationFields automatically as invalid
      if model_class.included_modules.include?(SelfRelationModule)
        invalid_params << {"new_related_#{model_class.model_name.plural}" => {"id" => ["1", "4"], "category" => ["haah cat!", "hooo cat"]}} if valid_params.select {|a| a.is_a?(Hash) ?  a.key?("new_related_#{model_class.model_name.plural}") : false }.empty?
        invalid_params << {"update_related_#{model_class.model_name.plural}" => {"5" => {"category" => "Cats!"}}} if valid_params.select {|a| a.is_a?(Hash) ?  a.key?("update_related_#{model_class.model_name.plural}") : false }.empty?
        invalid_params << ["remove_related_#{model_class.model_name.plural}"] unless valid_params.include?(["remove_related_#{model_class.model_name.plural}"])
      end
    end

    describe 'Strong Parameters' do
      describe "Method: #{filter_method}" do
        it "#{model_param_class.name} responds to #{filter_method}" do
          expect(model_param_class).to respond_to(filter_method)
        end

        it "accepts and rejects the right params" do
          param_hash = {}
          (valid_params + invalid_params).uniq.each do |param|
            param_hash[param] = param if param.is_a? String
            param_hash[param[0]] = [param[0]] if param.is_a? Array
            param_hash[param.keys[0]] = param_generator(param.values[0]) if param.is_a? Hash
          end
          params = parameter_object(param_hash,base_key)
          params[:id] = @user.id if filter_method == "profile_filter"
          valid_param_hash = {}
          valid_params.each do |param|
            valid_param_hash[param] = param if param.is_a? String
            valid_param_hash[param[0]] = [param[0]] if param.is_a? Array
            valid_param_hash[param.keys[0]] = param_generator(param.values[0]) if param.is_a? Hash
          end
          valid_parameters = parameter_object(valid_param_hash,base_key).permit!
          strong_params = model_param_class.send(filter_method,params,@user)
          expect(strong_params).to eq(base_key.nil? ? valid_parameters : valid_parameters[base_key])
        end

        describe "Valid Parameters" do #Individual tests. Yes, redundant, but I'm just learning this!
          valid_params.each do |param|
            if param.is_a? String
              it "accepts #{param} as a valid scalar" do
                params = parameter_object({param => "string"}, base_key) #defaults as not permitted
                params[:id] = @user.id if filter_method == "profile_filter"
                strong_params = model_param_class.send(filter_method,params,@user)
                params.permit! #Sets the params as permitted
                expect(strong_params).to eq(base_key.nil? ? params : params[base_key])
              end
            elsif param.is_a? Array
              it "accepts #{param[0]} as an valid array" do
                params = parameter_object({param[0] => [param[0]]}, base_key)  #defaults as not permitted
                params[:id] = @user.id if filter_method == "profile_filter"
                strong_params = model_param_class.send(filter_method,params,@user)
                params.permit! #Sets the params as permitted
                expect(strong_params).to eq(base_key.nil? ? params : params[base_key])
              end
            elsif param.is_a? Hash
              it "accepts #{param.keys[0]} as a valid hash" do
                params = parameter_object({param.keys[0] => param_generator(param.values[0])}, base_key) #defaults as not permitted
                params[:id] = @user.id if filter_method == "profile_filter"
                strong_params = model_param_class.send(filter_method,params,@user)
                params.permit! #Sets the params as permitted
                expect(strong_params).to eq(base_key.nil? ? params : params[base_key])
              end
            end
          end
        end

        describe "Invalid Parameters" do  #Individual tests. Yes, redundant, but I'm just learning this!
          invalid_params.each do |param|
            if param.is_a? String
              it "rejects #{param} as an invalid scalar" do
                params = parameter_object({param => "string"}, base_key)
                params[:id] = @user.id if filter_method == "profile_filter"
                strong_params = model_param_class.send(filter_method,params,@user)
                expect(strong_params).to be_empty
              end
            elsif param.is_a? Array
              it "rejects #{param[0]} as an invalid array" do
                params = parameter_object({param[0] => [param[0]]}, base_key)
                params[:id] = @user.id if filter_method == "profile_filter"
                strong_params = model_param_class.send(filter_method,params,@user)
                expect(strong_params).to be_empty
              end
            elsif param.is_a? Hash
              it "rejects #{param.keys[0]} as an invalid hash" do
                params = parameter_object({param.keys[0] => param_generator(param.values[0])}, base_key)
                params[:id] = @user.id if filter_method == "profile_filter"
                strong_params = model_param_class.send(filter_method,params,@user)
                expect(strong_params).to be_empty
              end
            end
          end
        end
      end
    end

    def parameter_object(hash,base_key)
      if base_key.nil?
        ActionController::Parameters.new(hash)
      else
        ActionController::Parameters.new(base_key => hash)
      end
    end

    def param_generator(value)
      if value.is_a?(String)
        {value => "string"}
      elsif value.is_a?(Array)
        {value[0] => ["string"]}
      elsif value.is_a?(Hash) && value.keys[0] == "update" # update_references: {"update" => ["url", "site_name"]}
        {"5" => value["update"].collect do |i|
          if i.is_a?(String)
            [i,i]
          elsif i.is_a?(Array)
            [i[0],i]
          elsif i.is_a?(Hash)
            [i.keys[0], param_generator(i.values[0])]
          end
        end.to_h }
      elsif value.is_a?(Hash) && value.keys[0] == "new" # new_references: {"new" => ["site_name", "url"]}
        value["new"].collect { |i| [i,[i,i]]}.to_h
      elsif value.is_a?(Hash)
        {value.keys[0] => param_generator(value.values[0])}
      else
        {key: "value", hash: {newhash: "oh no!"}}
      end
    end

  end

end
