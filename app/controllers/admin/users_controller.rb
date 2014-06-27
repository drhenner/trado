class Admin::UsersController < ApplicationController

  before_filter :authenticate_user!, :except => :new
  load_and_authorize_resource
  layout 'admin'

    def edit
        @user = current_user
        @attachment = @user.build_attachment unless @user.attachment
        respond_to do |format|
            format.html
            format.json { render :json => @user }   
        end
    end

    def update
        @user = current_user

        respond_to do |format|
          if @user.update_attributes(params[:user])
            flash_message :success, 'Profile was successfully updated.'
            format.html { redirect_to admin_root_url }
            format.json { head :no_content }
          else
            flash_message :error, 'There was an error when attempting to update your profile details.'
            format.html { render action: "edit" }
          end
        end
    end
    
end