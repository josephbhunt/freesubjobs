class JobsController < ApplicationController
  
  include AesopConnectHelper, HtmlParseHelper
  layout "application"
  
  before_filter :find_user, :only => [:index, :show, :new]
  before_filter :find_job, :only => [:show, :update]
  
  def index
  end
  
  def show
  end
  
  def create
  end
  
  def new
    if aesop_details_page(@user, params[:absr_id])
      @job = get_details_for_accepet(@user.response_body)
      if aesop_accept_job(@user, @job.hcc, params[:absr_id])
        @job.save
        flash[:notice] = "You have accepted this job!"
        redirect_to @job
      else
        flash[:notice] = "Job accept failed! You may need to logout and log back in, or the job may no longer be available."
        redirect_to @user
      end      
    else
      flash[:notice] = "Job accept failed! You may need to logout and log back in, or the job may no longer be available."
      redirect_to @user
    end
  end
  
  def update
  end
  
  def destroy
  end
  
  def find_user
    @user = User.find(params[:user_id])
  end
  
  def find_job
    @job = Job.find(params[:id])
  end
end