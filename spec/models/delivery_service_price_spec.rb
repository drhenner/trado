require 'rails_helper'

describe DeliveryServicePrice do

    # ActiveRecord relations
    it { expect(subject).to have_many(:orders).dependent(:restrict_with_exception).with_foreign_key('delivery_id') }
    it { expect(subject).to belong_to(:delivery_service) }
    it { expect(subject).to have_many(:countries).through(:delivery_service) }

    # Validations
    it { expect(subject).to validate_presence_of(:code) }
    it { expect(subject).to validate_presence_of(:price) }
    it { expect(subject).to validate_presence_of(:min_weight) }
    it { expect(subject).to validate_presence_of(:max_weight) }
    it { expect(subject).to validate_presence_of(:min_length) }
    it { expect(subject).to validate_presence_of(:max_length) }
    it { expect(subject).to validate_presence_of(:min_thickness) }
    it { expect(subject).to validate_presence_of(:max_thickness) }

    it { expect(subject).to validate_uniqueness_of(:code).scoped_to([:active, :delivery_service_id]) }

    it { expect(subject).to ensure_length_of(:description).is_at_most(180) }

    describe "Default scope" do
        let!(:delivery_service_price_1) { create(:delivery_service_price, price: '1.22') }
        let!(:delivery_service_price_2) { create(:delivery_service_price, price: '5.67') }
        let!(:delivery_service_price_3) { create(:delivery_service_price, price: '110.23') }

        it "should return an array of products ordered by descending weighting" do
            expect(DeliveryServicePrice.last(3)).to match_array([delivery_service_price_1, delivery_service_price_2, delivery_service_price_3])
        end
    end

    describe "Listing all shippings" do
        let!(:delivery_service_price_1) { create(:delivery_service_price, active: true) }
        let!(:delivery_service_price_2) { create(:delivery_service_price) }
        let!(:delivery_service_price_3) { create(:delivery_service_price, active: true) }

        it "should return an array of 'active' shippings" do
            expect(DeliveryServicePrice.active).to match_array([delivery_service_price_1, delivery_service_price_3])
        end
    end

    describe "Displaying the delivery service name" do
        let!(:delivery_service) { create(:delivery_service, active: true, courier_name: 'Royal Mail', name: 'Next day delivery') }
        let!(:delivery_service_price) { create(:delivery_service_price, active: true, delivery_service_id: delivery_service.id) }

        it "should return a string of the parent delivery services' courier name and service name" do
            expect(delivery_service_price.full_name).to eq 'Royal Mail Next day delivery'
        end
    end

    describe "Displaying a delivery service description" do

        context "if the delivery service has a description value" do
            let!(:delivery_service) { create(:delivery_service, description: 'Hi this is a delivery service description.', active: true) }
            let(:delivery_service_price) { create(:delivery_service_price, active: true, delivery_service_id: delivery_service.id, description: 'This is a delivery service price description.') }

            it "should return the delivery service description" do
                expect(delivery_service_price.full_description).to eq 'Hi this is a delivery service description.'
            end
        end

        context "if the delivery service has a nil description value" do
            let!(:delivery_service) { create(:delivery_service, description: nil, active: true) }
            let(:delivery_service_price) { create(:delivery_service_price, active: true, delivery_service_id: delivery_service.id, description: 'This is a delivery service price description.') }

            it "should return the delivery service price description" do
                expect(delivery_service_price.full_description).to eq 'This is a delivery service price description.'
            end
        end
    end
end