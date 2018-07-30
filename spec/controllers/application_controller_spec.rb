require 'rails_helper'

describe ApplicationController do
  before :each do
    activate_authlogic
  end
  
  controller do #anonymous controller to test Application Controller methods 
    def index
      raise CanCan::AccessDenied 
    end
    
    def new
      raise ActiveRecord::RecordNotFound
    end
  end
  
  describe "Error Handling" do
    context "CanCan::AccessDenied" do
      it "redirects to access_denied" do
        get :index
        expect(response).to render_template("pages/access_denied")
      end
      
      it "returns forbidden on js" do
        get :index, format: :js
        expect(response.status).to eq(403)
      end
      
      it "returns forbiddenon json" do
        get :index, format: :json
        expect(response.headers['Content-Type']).to match 'application/json'
        expect(response.status).to eq(403)
      end  
    end
    
    context "ActiveRecord::RecordNotFound" do
      it "renders record_not_found" do
        get :new
        expect(response).to render_template("pages/record_not_found")
      end
      
      it "returns not_found on json" do
        get :new, format: :json
        expect(response.headers['Content-Type']).to match 'application/json'
        expect(response.status).to eq(404)
      end
    end
  end
  
  describe "Param Modification" do
    describe "handle_partial_date_assignment" do
      context "all dates present" do 
        let(:params) {{"akari" => {"hohe" => {"release_date(1i)" => "1950","release_date(2i)" => "5","release_date(3i)" => "1"}}}}
                           
        it "passes the dates through normally" do
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params["akari"]["hohe"]).to include({"release_date(1i)" => "1950","release_date(2i)" => "5","release_date(3i)" => "1"})
        end
        
        it "has a bitmask of 0" do
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params["akari"]["hohe"]["release_date_bitmask"]).to eq(0)
        end
        
        it "does not modify a bitmask value if one is presenst" do
          params["akari"]["hohe"]["release_date_bitmask"] = 4
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params["akari"]["hohe"]["release_date_bitmask"]).to eq(4)
        end
      end
      
      context "Actual date object passed in" do
        let(:params) {{"ha" =>{"release_date" => Date.today}}}
        
        it "adds a bitmask of 0" do
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params["ha"]["release_date_bitmask"]).to eq(0)          
        end
        
        it "passes the date normally" do
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params["ha"]["release_date"]).to eq(Date.today)          
        end
      end
      
      context "with completely empty date fields" do
        let(:params) {{"release_date(1i)" => "","release_date(2i)" => "","release_date(3i)" => ""}}

        it "adds a bitmask of nil" do
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params.key?("release_date_bitmask")).to be true
          expect(params["release_date_bitmask"]).to be_nil
        end
        
        it "overwrites a date object that is passed in" do
          params["release_date"] = Date.today
          params[:release_date] = Date.today
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params[:release_date]).to be_nil
          expect(params["release_date"]).to be_nil
        end
        
        it "does not modify the empty date fields" do
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params).to include({"release_date(1i)" => "","release_date(2i)" => "","release_date(3i)" => ""})          
        end
      end
      
      context "with partial date" do
        let(:params) {{"release_date(1i)" => "1950","release_date(2i)" => "","release_date(3i)" => "1"}}

        it "adds a bitmask to params" do
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params["release_date_bitmask"]).to eq(2)          
        end
        
        it "replaces empty date_fields with 1 (or 1900 for year)" do
          ApplicationController.new.handle_partial_date_assignment(params,Album)
          expect(params["release_date(2i)"]).to eq("1")          
        end
      end
      
      context "with array dates" do
        it "handles array dates" do
          params = {"albums" => {"new_songs" => {"internal_name" => ["akari", "aika", "alice", "alicia"],
                                                 "release_date(1i)" => ["1955", "", "1922", "2012"],
                                                 "release_date(2i)" => ["6", "", "", "2"], 
                                                 "release_date(3i)" => ["2", "5", "2", ""]}}}
          ApplicationController.new.handle_partial_date_assignment(params,Song)
          expect(params["albums"]["new_songs"]["release_date(1i)"]).to eq(["1955", "1900", "1922", "2012" ])  
          expect(params["albums"]["new_songs"]["release_date(2i)"]).to eq(["6", "1", "1", "2" ])  
          expect(params["albums"]["new_songs"]["release_date(3i)"]).to eq(["2", "5", "2", "1" ])  
          expect(params["albums"]["new_songs"]["release_date_bitmask"]).to eq([0, 3, 2, 4])  
        end
      end
      
      context "with multiple partial_date fields" do
        it "handles multiple different partial date fields" do
          params = {"artist" => {"birth_date(1i)" => "1950","birth_date(2i)" => "","birth_date(3i)" => "1",
                                  "debut_date(1i)" => "1959","debut_date(2i)" => "4","debut_date(3i)" => ""}}
          ApplicationController.new.handle_partial_date_assignment(params,Artist)
          expect(params["artist"]["birth_date_bitmask"]).to eq(2)
          expect(params["artist"]["debut_date_bitmask"]).to eq(4)
        end
        
        it "handles multiple of the same fields" do
          params = {"songs" => {"1" => {"release_date(1i)" => "1995","release_date(2i)" => "","release_date(3i)" => ""},
                                "2" => {"release_date(1i)" => "","release_date(2i)" => "5","release_date(3i)" => "20"}}}  
          ApplicationController.new.handle_partial_date_assignment(params,Song)
          expect(params["songs"]["1"]["release_date_bitmask"]).to eq(6)
          expect(params["songs"]["2"]["release_date_bitmask"]).to eq(1)
        end
        
      end
    end
    
    describe "handle_length_format" do
      context "with :" do
        it "converts the value to the right integer" do
          params = {"length" => "2:44"}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["length"]).to eq(164)
        end
                
        it "handles 0:xx values properly" do
          params = {"length" => "00:55"}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["length"]).to eq(55)
        end
                
        it "handles x:y values properly" do
          params = {"alicia" => {"araara" => {"length" => "08:2"}}}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["alicia"]["araara"]["length"]).to eq(482)
        end
                
        it "handles 0x:0x values properly" do
          params = {"length" => "08:22"}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["length"]).to eq(502)
        end
        
        it "rejects x:yy:zz and replaces it with nil" do
          params = {"ho" => {"length" => "1:21:21"}}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["ho"]["length"]).to be_nil
        end
      end
      
      context "with multiple length fields" do
        it "handles multiple length fields" do
          params = {"songs" => {"1" => {"length" => "423"}, 
                                "2" => {"length" => "211:22"},
                                "3" => {"length" => "haha"}}}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["songs"]["1"]["length"]).to eq(423)
          expect(params["songs"]["2"]["length"]).to eq(12682)
          expect(params["songs"]["3"]["length"]).to be_nil
        end
      end
      
      context "with length as an array field" do
        it "handles length as an array field" do
          params = {"new_songs" => {"length" => ["322","21:21","haho","02:12"]}}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["new_songs"]["length"]).to eq([322,1281,nil,132])
        end
      end
      
      context "without :" do
        it "accepts leading zeroes" do
          params = {"length" => "00232"}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["length"]).to eq(232)
        end
        
        it "accepts a regular int with no leading zeros" do
          params = {"length" => "6431"}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["length"]).to eq(6431)
        end
          
      end
      
      context "Not of the m:ss form or an int" do
        it "replaces the length with nil" do
          params = {"length" => "2382aaa"}
          ApplicationController.new.handle_length_assignment(params)
          expect(params["length"]).to be_nil
        end
      end
    end
  end
end


