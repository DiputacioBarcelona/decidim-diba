class CensusesController < ApplicationController

  def show
    @censuses = OpenStruct.new(count: Census.count, last_import_at: Census.last_import_at)
  end

  def create
    Census.import(params[:file].path) if params[:file]
    redirect_to census_path
  end

end
