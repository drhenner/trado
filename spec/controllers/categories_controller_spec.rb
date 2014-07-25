require 'rails_helper'

describe CategoriesController do

    store_setting

    describe 'GET #show' do
        let(:category) { create(:category) }
        
        it "should assign the requested category to @category" do
            get :show, id: category.id
            expect(assigns(:category)).to eq category
        end
        it "should render the :show template" do
            get :show, id: category.id
            expect(response).to render_template :show
        end 
    end

end