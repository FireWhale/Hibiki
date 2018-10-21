class GraphController < ApplicationController

  def graph
    @query = NeoQueryer.perform(params[:model],params[:type] || 'info', id: params[:id], page: params[:page], limit: 10)

    respond_to do |format|
      format.html {render layout: 'full'}
      format.json {render json: @query[:paged] }
    end
  end

  def info
    if %w(Album Artist Organization Source Song Season Event Tag).include?(params[:model])
      @record = params[:model].capitalize.constantize.find_by_id(params[:id])
    end

    respond_to do |format|
      format.js
    end
  end
end
