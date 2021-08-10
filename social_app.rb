# frozen_string_literal: true

require_relative 'fetch_socials_service'
require 'dry-monads'

class SocialApp
  HEADERS = { 'Content-Type' => 'application/json' }.freeze

  include Dry::Monads[:result]

  def initialize
    @fetch_socials_service = FetchSocialsService.new
  end

  def call(_env)
    case @fetch_socials_service.call
    in Success(result)
    [200, HEADERS, [result.to_json]]
    in Failure(reason)
    [500, HEADERS, [{errors: reason}.to_json]]
    end
  end
end
