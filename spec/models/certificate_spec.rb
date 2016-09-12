describe Certificate do
  subject(:certificate) do
    FactoryGirl.create(:certificate)
  end

  it "should be valid?" do
    expect(certificate).to be_valid
  end

  it "should have a body" do
    expect(certificate.body.length).not_to eq(0)
  end

  it "should have a unique private_key" do
    new_certificate = certificate.dup
    certificate.save
    expect(new_certificate).not_to be_valid
  end

  it "should belong to only one customer" do
    expect(certificate.customer.email_address).to eq(FactoryGirl.build(:customer).email_address)
  end
end
