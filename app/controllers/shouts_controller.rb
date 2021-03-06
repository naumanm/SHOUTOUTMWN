class ShoutsController < ApplicationController
  #before_action :find_profile, only: [:index, :edit, :show, :destroy] 
  def index
    @category_id = params[:category_id]
    if @category_id
      @shouts = Shout.where(category_id: @category_id)
    else
      @shouts = Shout.order('created_at DESC')
    end
    @profile = Profile.find params[:profile_id]
    @categories = Category.all
    respond_to do |format|
      format.html # index.html.erb
      format.json {render :json => @shouts}
    end
  end

  def create
    @profile = Profile.find_by_id(params[:profile_id])
    @shout = Shout.new shout_params
    @shout.profile = @profile
    if @shout.save
      #notify
      redirect_to profile_shouts_path @profile
    else
      flash[:error] = "Shout information insufficient. Complete all fields and submit again"
      redirect_to new_profile_shout_path 
    end
  end

  def new
    @shout = Shout.new
    @categories = Category.all
    @profile = Profile.find_by_id(params[:profile_id])
  end

 
  def edit
    @profile = Profile.find_by_id(params[:profile_id])
    @shout = Shout.find_by_id(params[:id])
    @categories = Category.all
  end


  def update
    @shout = Shout.find_by_id(params[:id])
    @profile = Profile.find_by_id(params[:profile_id]) 
    @shout.profile_id = params[:profile_id]
    if @shout.update_attributes shout_params
      notify
      redirect_to profile_shout_path
    else
      flash[:error] = "Shout information insufficient. Complete all fields and submit again"
      redirect_to edit_profile_shout_path
    end
  end


  def show
    @profile = Profile.find params[:profile_id]
    @shout = Shout.find_by_id(params[:id])
    @category = Category.all
  end

  def destroy
    #profile = Profile.find params[:profile_id]
    shout = Shout.find params[:id]
    shout.destroy
    redirect_to profile_shouts_path(shout.profile)
    ##this redirect with the shout.profile used to work...not sure why it isn't anymore. tim explaine that a shout had a profile and that's why we have referenced it this way.

  end

  private 

  skip_before_action :verify_authenticity_token

  def notify
    # all this needs to be read from the DB and put in a loop
    twilio_account_sid = "ACcd6e84ce13b4e855c70761899db8f75e"
    twilio_auth_token = "9b9ae629188f4baf43df84ebeb700c25"
    body_text = 'NEW Shout! ' + 'from ' + @profile.username + ' '  + @shout.title

    profiles = Profile.all

    profiles.each do |profile|
      if profile.notification
        # need to wrap this in error handling
        to_number = '+1' + profile.phone_number    
        from_number = '+17078818036'
        client = Twilio::REST::Client.new twilio_account_sid, twilio_auth_token
        message = client.account.messages.create(:body => body_text,
            :to => to_number,
            :from => from_number)
        puts message.to

      end
    end
  end

  def shout_params
    params.require(:shout).permit(:id, :profile_id, :category_id, :title, :time, :description, :location)
  end

  def profile_params
    params.require(:profile).permit(:id, :username, :email, :password, :phone_number, :notification)
  end

  #  def find_profile
  #   @profile = Profile.find params[:profile_id]
  # end
end


