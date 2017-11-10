Rails.application.routes.draw do
  mount Census::Engine => '/census'
end
