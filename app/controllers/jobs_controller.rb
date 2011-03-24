class JobsController < ApplicationController
  
  include AesopConnectHelper, HtmlParseHelper
  layout "application"
  
  before_filter :find_user, :only => [:index, :show, :create]
  
  def index
  end
  
  def show
  end
  
  def create
  end
  
  def new
  end
  
  def update
  end
  
  def destroy
  end
  
  def find_user
    @user = User.find_by_id(params[:id])
  end
end