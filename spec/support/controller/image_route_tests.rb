require 'rails_helper'

module ImageRouteTests
  #GETS - Showing info
    shared_examples 'has an images page' do |accessible, route|
      model_class = described_class.controller_name.classify.constantize
      model_symbol = model_class.model_name.param_key.to_sym
      
      describe 'GET #show_images' do
        if accessible == true
          it "populates a #{model_symbol} record" do 
            record = create(model_symbol)
            get route, params: {id: record}
            expect(assigns(model_symbol)).to eq(record)
          end
          
          it "populates an image record" do
            record = create(model_symbol, :with_image)
            get route, params: {id: record}
            expect(assigns("image")).to eq(record.images.first)
          end
          
          it "responds to js" do
            record = create(model_symbol, :with_image)
            get route, xhr: true, params: {id: record}, format: :js
            expect(response).to render_template(:update_image)
          end    
                  
          it "returns a list of image records as json" do
            record = create(model_symbol)
            5.times do
              create(:imagelist, model: record)
            end
            get route, params: {id: record}, format: :json
            expect(response.headers['Content-Type']).to match 'application/json'
            expect(response.body).to eq(record.images.to_json)
          end          
        end
       
        it "renders the images template" do
          record = create(model_symbol)
          get route, params: {id: record}
          valid_permissions(:show_images, accessible)
        end
      end
    end
            
end
