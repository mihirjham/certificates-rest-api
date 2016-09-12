class Api::V1::CustomersController < BaseApiController

  def create
    @customer = Customer.new(customer_params)
    return api_error(:conflict, @customer.errors.full_messages) unless @customer.valid?

    if @customer.save
      render json: @customer, status: :created
    else
      api_error(:bad_request, "Invalid request error")
    end
  end

  def destroy
    @customer = Customer.find_by(id: params[:id])
    return api_error(404) unless @customer

    if @customer.destroy
      head status: 204
    else
      api_error(500)
    end
  end

  private
    def customer_params
      params.require(:customer).permit(:name, :email_address)
    end
end
