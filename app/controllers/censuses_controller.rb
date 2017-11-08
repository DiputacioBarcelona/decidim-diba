class CensusesController < ApplicationController

  def show
    @count = Census.count
    @last = Census.last
    @all = Census.all
  end

  def create
    Census.import(params[:file].path) if params[:file]
    redirect_to census_path
  end
end
