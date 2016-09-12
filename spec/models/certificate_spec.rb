describe Certificate do
  subject(:certificate) do
    FactoryGirl.build(:certificate)
  end

  it "should be valid?" do
    expect(certificate).to be_valid
  end

  it "should have a body" do
    certificate.body = ""
    expect(certificate).not_to be_valid
  end

  it "should have a customer_id" do
    certificate.customer_id = nil
    expect(certificate).not_to be_valid
  end

  it "should have a unique private_key" do
    new_certificate = certificate.dup
    certificate.save
    expect(new_certificate).to be_valid
  end

  it "should belong to only one customer" do
    expect(certificate.customer.email_address).to eq(FactoryGirl.build(:customer).email_address)
  end
end
