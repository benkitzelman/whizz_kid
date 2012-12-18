class RootController < WhizzKid::BaseController
  mount_assets

  get '/' do
    erb :index
  end
end