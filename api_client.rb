# frozen_string_literal: true

require 'net/http'
require 'dry-monads'
require 'json'

class ApiClient
  include Dry::Monads[:result, :try]
  include Dry::Monads::Do.for(:call)
  def call(uri)
    res = yield Try { Net::HTTP.get_response(URI(uri)) }.to_result

    return Try { JSON.parse(res.body) }.to_result if res.is_a?(Net::HTTPOK)

    # We can do so much better here by tracking a reason of failure(fail to parse json or bad status code) but im lazy
    Failure(:third_party_error)
  end
end
