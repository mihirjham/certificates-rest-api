describe Api::V1::CustomersController, type: :controller do
  context 'create' do
    subject(:customer) { FactoryGirl.build(:customer) }

    before do
      post :create, customer: customer.as_json, format: :json
    end

    it "returns a status of 201" do
      expect(response.status).to eq(201)
    end

    it "returns a status of 409 if already exists" do
      post :create, customer: customer.as_json, format: :json
      expect(response.status).to eq(409)
    end

  end
end
