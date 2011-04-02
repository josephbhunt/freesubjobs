class UsersController < ApplicationController
  
  include AesopConnectHelper, HtmlParseHelper
  layout "application"
  
  before_filter :find_user, :only => [:show, :logout, :accept_job, :reject_job]
  
  def index
  end
  
  def new
  end
  
  def create
    if User.registered?(params[:user][:aesop_id])
      flash[:reg_error] = "There is already a user with that Aesop id!"
    else
      @user = User.new do |u|
        u.aesop_id = params[:user][:aesop_id]
        u.email = params[:user][:email]
        u.user_agent = request.headers["HTTP_USER_AGENT"]
      end
      if login_aesop(@user, params[:user][:aesop_pin])
        if @user.save
          redirect_to @user and return
        else
          flash[:reg_error] = "Registration Failed!"
        end
      else
        flash[:reg_error] = "Failed to login to Aesop!\nEither your Aesop id or Aesop pin is incorrect."
      end
    end
    redirect_to root_path
  end
  
  def update
  end
  
  def destroy
  end
  
  def show
    if aesop_job_list(@user)
      @districts_with_jobs = scrape_district_info(@user.response_body)
    else
      redirect_to root_path
    end
    if request.xhr?
      render :partial => "job_list"
    end
  end
  
  def edit
  end
  
  def login
    @user = User.find_by_email(params[:user][:email])
    if @user
      if login_aesop(@user, params[:user][:aesop_pin])
        redirect_to @user and return
      else
        flash[:login_error] = "Failed to login to Aesop!\nEither your Aesop id or Aesop pin is incorrect."
      end
    else
      flash[:login_error] = "You are not registered with FreeSubJobs.org!"
    end
    redirect_to root_path
  end
  
  def logout
    aesop_logout(@user)
    redirect_to root_path
  end
  
  def reject_job
    if aesop_details_page(@user, params[:absr_id])
      hcc = get_details_for_reject(@user.response_body)
      if aesop_reject_job(@user, hcc, params[:absr_id])
        flash[:notice] = "You have rejected a job"
        redirect_to @user
      else
        flash[:notice] = "Job reject failed! You may need to logout and log back in, or the job may no longer be available."
        redirect_to @user
      end      
    else
      flash[:notice] = "Job reject failed! You may need to logout and log back in, or the job may no longer be available."
      redirect_to @user
    end
  end
  
  def find_user
    @user = User.find_by_id(params[:id])
  end
end
