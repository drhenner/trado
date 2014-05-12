class Admin::AdminController < ApplicationController
    
    before_filter :authenticate_user!
    layout 'admin'

    def dashboard 

    end

    def settings
        @settings = Store::settings
        @attachment = @settings.build_attachment unless @settings.attachment
    end

    def update
        @settings = Store::settings
        
        respond_to do |format|
          if @settings.update_attributes(params[:store_setting])
            Store::reset_settings
            flash[:success] = 'Store settings were successfully updated.'
            format.html { redirect_to admin_root_path }
            format.json { head :no_content }
          else
            format.html { render action: "settings" }
            format.json { render json: @settings.errors, status: :unprocessable_entity }
          end
        end
    end
    
end