describe Customer do
  subject(:customer) do
    FactoryGirl.build(:customer)
  end

  it "should be valid?" do
    expect(customer).to be_valid
  end

  it "name should be present" do
    customer.name = "     "
    expect(customer).not_to be_valid
  end

  it "email_address should be present" do
    customer.email_address = "   "
    expect(customer).not_to be_valid
  end

  it "name should not be too long" do
    customer.name = "a" * 51
    expect(customer).not_to be_valid
  end

  it "email_address should not be too long" do
    customer.email_address = "a" * 256
    expect(customer).not_to be_valid
  end

  it "valid email_address should be accepted" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      customer.email_address = valid_address
      expect(customer).to be_valid
    end
  end

  it "invalid email_address should be rejected" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      customer.email_address = invalid_address
      expect(customer).not_to be_valid
    end
  end

  it "email_address should be unique" do
    new_customer = customer.dup
    customer.save!
    expect(new_customer).not_to be_valid
  end
end
