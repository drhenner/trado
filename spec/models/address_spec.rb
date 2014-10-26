require 'rails_helper'

describe Address do

    # ActiveRecord relations
    it { expect(subject).to belong_to(:order) }
    it { expect(subject).to belong_to(:addressable) }
    
    # Validations
    it { expect(create(:address)).to validate_presence_of(:first_name) }
    it { expect(create(:address)).to validate_presence_of(:last_name) }
    it { expect(create(:address)).to validate_presence_of(:address) }
    it { expect(create(:address)).to validate_presence_of(:city) }
    it { expect(create(:address)).to validate_presence_of(:postcode) }
    it { expect(create(:address)).to validate_presence_of(:country) }

    describe "When displaying an address" do
        let!(:address) { create(:address, first_name: 'John', last_name: 'Doe') }

        it "should return a contact's full name as a string" do
            expect(address.full_name).to eq 'John Doe'
        end
    end
end