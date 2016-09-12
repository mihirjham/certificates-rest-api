class Certificate < ActiveRecord::Base
  validates :customer_id, presence: true
  validates :private_key, presence: true, uniqueness: true
  validates :body, presence: true

  belongs_to :customer

  before_validation :generate_private_key

  def self.get_active_certificates_of_customer(customer_id)
    Certificate.where(customer_id: customer_id, active: true)
  end

  private
    def generate_private_key
      loop do
        self.private_key = SecureRandom.urlsafe_base64(16)
        break unless Certificate.find_by(private_key: self.private_key)
      end
    end
end
