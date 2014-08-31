require 'rails_helper'

describe Admin::StockLevelsController do

    store_setting
    login_admin

    describe 'GET #new' do
        let(:product) { create(:product) }
        let(:sku) { create(:sku, product_id: product.id) }

        it "should assign the requested SKU to @sku" do
            xhr :get, :new, product_id: product.id, sku_id: sku.id
            expect(assigns(:sku)).to eq sku
        end

        it "should render a new partial" do
            xhr :get, :new, product_id: product.id, sku_id: sku.id
            expect(response).to render_template(partial: 'admin/products/skus/stock_levels/_new')
        end
    end

    describe 'POST #create' do
        let(:product) { create(:product) }
        let(:sku) { create(:sku, product_id: product.id) }

        context "with valid attributes" do

            it "should save a new stock level to the database" do
                expect{
                    xhr :post, :create, product_id: product.id, sku_id: sku.id, stock_level: attributes_for(:stock_level)
                }.to change(StockLevel, :count).by(1)
            end

            it "should render the success partial" do
                xhr :post, :create, product_id: product.id, sku_id: sku.id, stock_level: attributes_for(:stock_level)
                expect(response).to render_template(partial: 'admin/products/skus/stock_levels/_create')
            end
        end

        context "with invalid attributes" do
            let(:errors) { ["Adjustment can't be blank"] }

            it "should not save the stock level to the database" do
                expect{
                    xhr :post, :create, product_id: product.id, sku_id: sku.id, stock_level: attributes_for(:stock_level, adjustment: nil)
                }.to change(StockLevel, :count).by(0)
            end

            it "should return a JSON object of errors" do
                xhr :get, :create, product_id: product.id, sku_id: sku.id, stock_level: attributes_for(:stock_level, adjustment: nil)
                expect(assigns(:stock_level).errors.full_messages).to eq errors
            end

            it "should return a 422 status code" do
                xhr :get, :create, product_id: product.id, sku_id: sku.id, stock_level: attributes_for(:stock_level, adjustment: nil)
                expect(response.status).to eq 422
            end
        end
    end
end