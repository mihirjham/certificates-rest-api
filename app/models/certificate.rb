class Certificate < ActiveRecord::Base
  validates :customer_id, presence: true
  validates :private_key, presence: true, uniqueness: true
  validates :body, presence: true

  belongs_to :customer

  before_validation :generate_private_key
  before_validation :generate_certificate

  def self.get_active_certificates_of_customer(customer_id)
    Certificate.where(customer_id: customer_id, active: true)
  end

  private
    def generate_private_key
      return if self.private_key

      loop do
        self.private_key = OpenSSL::PKey::RSA.new(2048).to_pem
        break unless Certificate.find_by(private_key: self.private_key)
      end
    end

    def generate_certificate
      return if self.body

      customer = Customer.find_by(id: self.customer_id)
      subject = "/CN=#{customer.name}/emailAddress=#{customer.email_address}"
      certificate = OpenSSL::X509::Certificate.new
      certificate.subject = certificate.issuer = OpenSSL::X509::Name.parse(subject)
      certificate.version = 2

      self.body = certificate.to_pem
    end
end
