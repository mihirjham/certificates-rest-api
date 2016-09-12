class Customer < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: { maximum: 50 }
  validates :email_address, presence: true, length: { maximum: 255 },
                            format: { with: VALID_EMAIL_REGEX },
                            uniqueness: true

  before_save :clean_email_address

  has_many :certificates, dependent: :destroy
  
  private
    def clean_email_address
      self.email_address = self.email_address.strip.downcase
    end
end
