class Customer < ActiveRecord::Base
  validates :name, :email_address, presence: true
  validates :email_address, uniqueness: true
end
