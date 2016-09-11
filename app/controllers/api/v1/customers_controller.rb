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
  end

  private
    def customer_params
      params.require(:customer).permit(:name, :email_address)
    end
end
