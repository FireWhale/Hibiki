require 'rails_helper'

module GlobalModelTests  
  shared_examples "global model tests" do
    model_symbol = described_class.model_name.param_key.to_sym
    
    describe "Functionality Tests" do
      #Make sure Factories are working
      describe "Factory" do
        it "has a valid factory" do
          instance = create(model_symbol)
          expect(instance).to be_valid
        end
      end
      
      #Adding or removing functionality will make these tests fail 

      describe "Collections" do
        if [Album, Song].include?(described_class)
          it "has the collection module" do
            expect(described_class.included_modules).to include(CollectionModule)   
          end          
        else
          it "does not have the collection module" do
            expect(described_class.included_modules).to_not include(CollectionModule)  
          end
        end
      end
      
      describe "Watchlists" do
        if [Artist, Source, Organization].include?(described_class)
          it "has the collection module" do
            expect(described_class.included_modules).to include(WatchlistModule)   
          end          
        else
          it "does not have the collection module" do
            expect(described_class.included_modules).to_not include(WatchlistModule)  
          end
        end        
      end
      
      describe "Self-relations" do
        if [Album, Song, Source, Organization, Artist].include?(described_class)
          it "has the self-relation module" do
            expect(described_class.included_modules).to include(SelfRelationModule)   
          end          
        else
          it "does not have the self-relation module" do
            expect(described_class.included_modules).to_not include(SelfRelationModule)  
          end
        end
      end
      
      describe "Images" do
        if [Album, Song, Artist, Source, Organization, User, Post, Season].include?(described_class)
          it "has the image module" do
            expect(described_class.included_modules).to include(ImageModule)   
          end
        else
          it "does not have the image module" do
            expect(described_class.included_modules).to_not include(ImageModule)   
          end
        end
      end
      
      describe "Posts" do
        if [Album, Song, Artist, Source, Organization].include?(described_class)
          it "has the post module" do
            expect(described_class.included_modules).to include(PostModule)   
          end
        else
          it "does not have the post module" do
            expect(described_class.included_modules).to_not include(PostModule)   
          end          
        end
      end
      
      describe "Tags" do
        if [Album, Artist, Song, Source, Organization, Post].include?(described_class)                    
          it "has the tag module" do
            expect(described_class.included_modules).to include(TagModule)            
          end
        else
          it "does not have the tag module" do
            expect(described_class.included_modules).to_not include(TagModule)            
          end
        end
      end
      
      describe "Translations" do
        if [Artist, Source, Organization, Album, Song, Event, Tag].include?(described_class)
          it "has the listed translations" do #This tests the translates :att1, :att2 line
            if described_class == Song
              expect(build(model_symbol).translated_attributes).to eq({"name"=>nil, "info"=>nil, "lyrics"=>nil})        
            elsif described_class == Event
              expect(build(model_symbol).translated_attributes).to eq({"name"=>nil, "info"=>nil, "abbreviation"=>nil})                     
            else
              expect(build(model_symbol).translated_attributes).to eq({"name"=>nil, "info"=>nil})            
            end
          end
          
          it "has the translation and language modules" do #this tests the included modules
            expect(described_class.included_modules).to include(Globalize::ActiveRecord::InstanceMethods)
            expect(described_class.included_modules).to include(LanguageModule)            
          end
        else
          it "does not have translations" do
            expect(build(model_symbol)).to_not respond_to(:translated_attributes)
          end
          
          it "does not have translation or language modules" do
            expect(described_class.included_modules).to_not include(Globalize::ActiveRecord::InstanceMethods)
            expect(described_class.included_modules).to_not include(LanguageModule)
          end
        end
      end
      
      describe 'Solr Search' do
        if [Artist, Source, Organization, Album, Song].include?(described_class)
          it "has the solr search module" do
            expect(described_class.included_modules).to include(Sunspot::Rails::Searchable::InstanceMethods)                        
          end
        else
          it "is not searchable" do
            expect(described_class.searchable?).to eq(false)
          end
          
          it "does not have the solr search module" do
            expect(described_class.included_modules).to_not include(Sunspot::Rails::Searchable::InstanceMethods)            
          end
        end
      end
      
      describe 'JSON' do
        if [Artist, Source, Organization, Album, Song, 
            Event, Season, Post, Issue, Tag, Image, User].include?(described_class)
          it "has the json module" do
            expect(described_class.included_modules).to include(JsonModule)                        
          end
        else          
          it "does not have the json module" do
            expect(described_class.included_modules).to_not include(JsonModule)            
          end
        end        
      end
      
    end
  end
  
  shared_examples "it has form_fields" do
    it "has a form_field constant" do
      expect(described_class.const_defined?("FormFields")).to be_truthy
    end
  end
end
