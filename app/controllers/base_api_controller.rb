class BaseApiController < ApplicationController
  before_action :destroy_session!

  protected
    def destroy_session!
      request.session_options[:skip] = true
    end

    def not_found!
      api_error(404, errors: 'Not found')
    end

    def api_error(status = 500, errors = [])
      render json: {error: errors}, status: status
    end

end
