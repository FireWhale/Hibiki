class GraphController < ApplicationController

  def graph

    respond_to do |format|
      format.html {render layout: 'full'}
    end
  end
end
