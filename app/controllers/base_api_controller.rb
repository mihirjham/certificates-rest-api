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
      if errors.empty?
        render nothing: true, status: status
      else
        render json: {error: errors}, status: status
      end
    end

    def paginate(model)
      model = model.page(params[:page] || 1)
      if params[:per_page]
        per_page = params[:per_page].to_i
        if per_page > 100
          per_page = 100
        end

        model = model.per(per_page)
      end

      model
    end

    def meta_attributes(model)
      {
        current_page: model.current_page,
        next_page: model.next_page,
        prev_page: model.prev_page,
        total_pages: model.total_pages,
        total_count: model.total_count
      }
    end
end
