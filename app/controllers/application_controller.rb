# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with name: ENV.fetch('AUTH_USER', nil),
                               password: ENV.fetch('AUTH_PASS', nil)

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def not_found
    render json: { error: 'not-found' }, status: :not_found
  end
end
