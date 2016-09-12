describe Api::V1::CustomersController, type: :controller do
  subject(:customer) { FactoryGirl.build(:customer) }
  context 'create' do
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

  context "destroy" do
    before do
      customer.save
      delete :destroy, id: customer.id
    end

    it "returns a status of 204 if successful" do
      expect(response.status).to eq(204)
    end

    it "returns a status of 404 if not found" do
      delete :destroy, id: customer.id
      expect(response.status).to eq(404)
    end
  end
end
