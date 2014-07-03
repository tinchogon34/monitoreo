class ApplicationController < ActionController::API
  rescue_from ActionController::RoutingError, with: :not_found_error
  def catch_404
    raise ActionController::RoutingError.new(params[:path])
  end

  private

  def not_found_error
    head :not_found
  end
end
