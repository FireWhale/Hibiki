class IssuesController < ApplicationController
  load_and_authorize_resource
  
  def index
    @issues = Issue.meets_role(current_user)
    @all_issues = @issues
    @issues = @issues.with_category(params[:category]) unless params[:category].nil?
    @issues = @issues.with_status(params[:status]) unless params[:status].nil?
    @issues = @issues.order(:status).reverse_order
    @issues = @issues.page(params[:page])
    
    respond_to do |format|
      format.html # index.html.erb
      format.json 
    end    
  end
  
  def show
    @issue = Issue.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json {@fields = (params[:fields] || '').split(',')}
    end
  end

  def new
    @issue = Issue.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @issue }
    end
  end
    
  def edit
    @issue = Issue.find(params[:id])
    
    respond_to do |format|
      format.html # edit.html.erb
      format.json { render json: @issue }
    end
  end
    
  def create
    @issue = Issue.new(issue_params)
    
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
      if @issue.update_attributes(issue_params)
        format.html { redirect_to @issue, notice: 'Issue was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @issue.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @issue = Issue.find(params[:id])
    @issue.destroy

    respond_to do |format|
      format.html { redirect_to issues_url }
      format.json { head :no_content }
    end
  end
  
  class IssueParams
    def self.filter(params,current_user)
      if current_user && current_user.abilities.include?("Admin")
        params.require(:issue).permit(:name, :category, :description, :private_info, :status, :priority, :visibility, :resolution, :difficulty)
      elsif current_user
        params.require(:issue).permit()
      else
        params.require(:issue).permit()
      end     
    end
  end
  
  private
    def issue_params
      IssueParams.filter(params,current_user)
    end  
end
