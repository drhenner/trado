require 'spec_helper'

describe Product do

    # ActiveRecord relations
    it { expect(subject).to have_many(:skus).dependent(:delete_all) }
    it { expect(subject).to have_many(:orders).through(:skus) }
    it { expect(subject).to have_many(:carts).through(:skus) }
    it { expect(subject).to have_many(:taggings).dependent(:delete_all) }
    it { expect(subject).to have_many(:tags).through(:taggings) }
    it { expect(subject).to have_many(:attachments).dependent(:delete_all) }
    it { expect(subject).to have_many(:accessorisations).dependent(:delete_all) }
    it { expect(subject).to have_many(:accessories).through(:accessorisations) }
    it { expect(subject).to belong_to(:category) }


    # Validation
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to validate_presence_of(:meta_description) }
    it { expect(subject).to validate_presence_of(:description) }
    it { expect(subject).to validate_presence_of(:part_number) }
    it { expect(subject).to validate_presence_of(:sku) }
    it { expect(subject).to validate_presence_of(:category_id) }
    it { expect(subject).to validate_presence_of(:weighting) }

    it { expect(subject).to validate_uniqueness_of(:name).scoped_to(:active) }
    it { expect(subject).to validate_uniqueness_of(:sku).scoped_to(:active) }
    it { expect(subject).to validate_uniqueness_of(:part_number).scoped_to(:active) }

    it { expect(subject).to validate_numericality_of(:part_number).is_greater_than_or_equal_to(1).only_integer } 

    it { expect(subject).to ensure_length_of(:name).is_at_least(10) }
    it { expect(subject).to ensure_length_of(:meta_description).is_at_least(10) }
    it { expect(subject).to ensure_length_of(:description).is_at_least(20) }

    # Nested attributes
    it { expect(subject).to accept_nested_attributes_for(:skus) }
    it { expect(subject).to accept_nested_attributes_for(:attachments) }
    it { expect(subject).to accept_nested_attributes_for(:tags) }

    describe "Listing all products" do
        let!(:product_1) { create(:product) }
        let!(:product_2) { create(:product, active: true) }
        let!(:product_3) { create(:product, active: true) }

        it "should return an array of active products" do
            expect(Product.active).to match_array([product_2, product_3])
        end
    end

    describe "Default scope" do
        let!(:product_1) { create(:product, weighting: 2000) }
        let!(:product_2) { create(:product, weighting: 3000) }
        let!(:product_3) { create(:product, weighting: 1000) }

        it "should return an array of products ordered by descending weighting" do
            expect(Product.last(3)).to match_array([product_2, product_1, product_3])
        end
    end

    describe "Setting a product as a single product" do
        let!(:product) { build(:build_product_skus, single: true) }
        context "when the product has more than one SKUs" do

            it "should produce an error" do
                product.valid?
                expect(product).to have(1).errors_on(:single)
                expect(product.errors.messages[:single]).to eq [" product cannot be set if the product has more than one SKU."]
            end
        end
    end
end
