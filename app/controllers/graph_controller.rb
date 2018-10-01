class GraphController < ApplicationController

  def graph

    @record = Album.find(23).neo_record

    respond_to do |format|
      format.html {render layout: 'full'}
    end
  end
end
