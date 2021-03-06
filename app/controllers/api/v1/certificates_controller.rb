class Api::V1::CertificatesController < BaseApiController
  def create
    @customer = Customer.find_by(id: params[:customer_id])
    return api_error(404, ["Customer not found"]) unless @customer

    @certificate = Certificate.new(customer: @customer)

    if @certificate.save
      render :certificate, status: 201
    else
      api_error(400, "Invalid request error")
    end
  end

  def active
    @customer = Customer.find_by(id: params[:customer_id])
    return api_error(404) unless @customer

    @certificates = Certificate.get_active_certificates_of_customer(@customer.id)
    @certificates = paginate(@certificates)
    @meta_attributes = meta_attributes(@certificates)

    render :active, status: 200
  end

  def activate
    handle_update(active: true)
  end

  def deactivate
    handle_update(active: false)
  end

  private
    def certificate_params
      params.require(:certificate).permit(:private_key)
    end

    def handle_update(options)
      @certificate = Certificate.find_by(private_key: certificate_params[:private_key])
      return api_error(404) unless @certificate

      if @certificate.update(options)
        if params[:notify]
           @response = RestClient.post(params[:notify][:host], params[:notify][:attributes].to_json, content_type: :json)
        end

        render :certificate, status: 200
      else
        api_error(500)
      end
    end
end
