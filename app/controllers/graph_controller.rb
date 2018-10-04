class GraphController < ApplicationController

  def graph
    @results = NeoQueryer.perform(params[:model],params[:id],params[:page],10)

    respond_to do |format|
      format.html {render layout: 'full'}
      format.json {render json: @results[:nodes] }
    end
  end
end
