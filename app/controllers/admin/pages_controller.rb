class Admin::PagesController < ApplicationController
  layout 'admin'

  def index
    @pages = Page.all
  end

  def edit
    set_page
    amazon_signature
    list_template_types
  end

  def update
    set_page
    amazon_signature
    list_template_types
    params[:page][:slug] = Store.parameterize_slug(params[:page][:slug])
    if @page.update(params[:page])
      flash_message :success, 'Page was successfully updated.'
      redirect_to admin_pages_url
    else
      render :edit
    end
  end

  private
  
  def set_page
    @page ||= Page.find(params[:id])
  end

  def list_template_types
    @template_types ||= Page.template_types
  end
end
