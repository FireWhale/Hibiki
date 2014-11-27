require 'rails_helper'

module ControllerTests  
  #GETS - Showing info
    shared_examples 'has an index page' do |model, valid|
      describe 'GET #index' do
        it "populates a list of #{model}s" do
          list = create_list(model.to_sym, 20)
          get :index
          expect(assigns("#{model}s".to_sym)).to match_array list
        end
        
        it "handles pagination properly"
        
        it "renders the :index template" do
          get :index
          valid_permissions(:index, valid)
        end
      end
    end
    
    shared_examples 'has a show page' do |model, valid|
      describe 'GET #show' do
        it "populates a #{model} record" do
          record = create(model.to_sym)
          get :show, id: record
          expect(assigns(model.to_sym)).to eq(record)
        end
        
        it "renders the :show template" do
          record = create(model.to_sym)
          get :show, id: record
          valid_permissions(:show, valid)
        end
      end
    end
    
    shared_examples 'has an images page' do |model, valid, method|
      describe 'GET #show_images' do
        it "populates a #{model} record" do 
          record = create(model.to_sym)
          get method, id: record
          expect(assigns(model.to_sym)).to eq(record)
        end
        
        it "renders the images template" do
          record = create(model.to_sym)
          get method, id: record
          valid_permissions(method, valid)
        end
      end
    end
    
  #GETS - Editing info
    shared_examples 'has a new page' do |model, valid|
      describe 'GET #new' do
        before(:each) {get :new}
        
        it "assigns a new #{model} record to @{model}" do
          expect(assigns(model.to_sym)).to be_a_new(model.capitalize.constantize)
        end
        
        it "renders the :new template" do
          valid_permissions(:new, valid)
        end
      end
    end
    
    shared_examples 'has an edit page' do |model, valid|
      describe 'GET #edit' do        
        it "populates a #{model} record" do
          record = create(model.to_sym)
          get :edit, id: record
          expect(assigns(model.to_sym)).to eq record
        end
        
        it "renders the :edit template" do
          record = create(model.to_sym)
          get :edit, id: record
          valid_permissions(:edit, valid)
        end
      end
    end
    
  #POSTS
    shared_examples 'can post create' do |model, valid|
      describe 'POST #create' do
        context "with valid attributes" do
          if valid == true          
            it "saves the new #{model}" do
              expect{post :create, model.to_sym => attributes_for(model.to_sym)}.to change(model.capitalize.constantize, :count).by(1)
            end          
            
            it "redirects to show" do
              post :create, model.to_sym => attributes_for(model.to_sym)
              expect(response).to redirect_to send("#{model}_path",(assigns[model.to_sym]))
            end
          elsif valid == false                    
            it "does not save the new #{model}" do
              expect{post :create, model.to_sym => attributes_for(model.to_sym)}.to change(model.capitalize.constantize, :count).by(0)            
            end  
            
            it "renders the #show template"
            
          else
            Raise Exception            
          end
         
        end
        
        context "with invalid attributes" do
          if valid == true        
            it "does not save the new #{model}" do
              expect{post :create, model.to_sym => attributes_for(model.to_sym, :invalid)}.to change(model.capitalize.constantize, :count).by(0)          
            end
            
            it "renders the :new template"
            
          elsif valid == false
            it "renders the :index template"
          end
        end     
      end
    end
    
    shared_examples 'can post update' do |model, valid, attribute|
      describe 'POST #update' do
        #attribute should be an string attribute that is invalid when blank
        context "with valid attributes" do
          before(:each) do
            @record = create(model.to_sym)
          end
          
          if valid == true
            it "locates the requested #{model}" do
              put :update, id: @record.id, model.to_sym => attributes_for(model.to_sym)
              expect(assigns(model.to_sym)).to eq(@record)
            end
            
            it "updates the #{model}" do
              put :update, id: @record.id, model.to_sym => attributes_for(model.to_sym, attribute => "valid!")     
              @record.reload
              expect(@record.send(attribute.to_s)).to eq("valid!")     
            end
            
            it "redirects to the #{model}" do
              put :update, id: @record, model.to_sym => attributes_for(model.to_sym)
              expect(response).to redirect_to @record
            end
          elsif valid == false
            it "does not update the #{model}" do
              original_value = @record.send(attribute.to_s)
              put :update, id: @record.id, model.to_sym => attributes_for(model.to_sym, attribute => "valid!")     
              @record.reload
              expect(@record.send(attribute.to_s)).to eq(original_value)    
            end
            
            it "redirects to the #{model}"
            
          else
            Raise Exception          
          end
          
  
        end
        
        context "with invalid attributes" do
          before(:each) do
            @record = create(model.to_sym)
          end
          # it "locates the requested #{model}" 
          # Covered by the valid attributes context
          
          it "does not update the #{model}" do
            if model == "event"
              put :update, id: @record.id, model.to_sym => attributes_for(model.to_sym, attribute => "", shorthand: "")  
            else
              put :update, id: @record.id, model.to_sym => attributes_for(model.to_sym, attribute => "")   
            end
            @record.reload
            expect(@record.send(attribute)).to_not eq("")
          end
          
          if valid == true
            it "renders the #edit template" do
            if model == "event"
              put :update, id: @record.id, model.to_sym => attributes_for(model.to_sym, attribute => "", shorthand: "")  
            else
              put :update, id: @record.id, model.to_sym => attributes_for(model.to_sym, attribute => "")   
            end
              expect(response).to render_template("edit")
            end
          elsif valid == false
            it "renders the #show template"
          end
        end
      end
    end
    
    shared_examples 'can delete a record' do |model, valid|
      describe 'DELETE #destroy' do
        before :each do
          @record = create(model.to_sym)
        end
        
        if valid == true
          it "destroys the #{model}" do
            expect{delete :destroy, id: @record}.to change(model.capitalize.constantize, :count).by(-1)
          end
          
          it "redirects to #index" do
            delete :destroy, id: @record
            expect(response).to redirect_to send("#{model}s_url")
          end        
        elsif valid == false
          it "does not destroy the #{model}" do
            expect{delete :destroy, id: @record}.to change(model.capitalize.constantize, :count).by(0)
          end
          
          it "redirects to #index"
          
        else
          Raise Exception
        end
      end
    end
        
  #Helper Methods  
    def valid_permissions(template, valid)
      valid ? (expect(response).to render_template template) : (expect(response).to render_template("pages/access_denied"))
    end
end
