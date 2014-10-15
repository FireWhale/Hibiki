class IssuesController < ApplicationController
  load_and_authorize_resource
  
  def index
    @issues = Issue.all.group_by(&:category)
  end
  
  def show
    @issue = Issue.find(params[:id])
    
  end
  
  def create
    @issue = Issue.new(params[:issue])
    
    respond_to do |format|
      if @issue.save
        format.html { redirect_to @issue, notice: 'Issue was successfully created.' }
        format.json { render json: @issue, status: :created, location: @song }
      else
        format.html { render action: "new" }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    @issue = Issue.find(params[:id])
    
    respond_to do |format|
      if @issue.update_attributes(params[:issue])
        format.html { redirect_to @issue, notice: 'Issue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
    
  end
  
  def edit
    @issue = Issue.find(params[:id])
  end
  
  def new
    @issue = Issue.new
  end
  
end
