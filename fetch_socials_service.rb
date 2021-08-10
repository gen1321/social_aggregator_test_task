# frozen_string_literal: true

require 'dry-monads'
require 'dry/monads/do'
require_relative 'api_client'

class FetchSocialsService
  include Dry::Monads[:task, :list, :result]
  include Dry::Monads::Do.for(:call)

  SOCIALS = [{ url: 'https://takehome.io/facebook', name: :facebook },
             { url: 'https://takehome.io/twitter', name: :twitter }].freeze

  def initialize
    @api_client = ApiClient.new
  end

  def call
    @errors = []
    tasks = SOCIALS.map do |params|
      fetch_social(params)
    end

    result = yield Dry::Monads::List::Task[*tasks].traverse.to_result
    result = handle_api_errors(result)

    Success(serialize(result))
  end

  private


  def handle_api_errors(result)
    result.value.map do |social|
      social.each_with_object({}) do |(key, monadic_result), acc|
        if monadic_result.success?
          acc[key] = monadic_result.value!
        else
          @errors.push({ key => monadic_result.failure })
        end
      end
    end
  end

  def fetch_social(name:, url:)
    Task { { name => @api_client.call(url) } }
  end

  # in real world project i would use a real serializer. its realy a just a crutch
  def serialize(result)
    result = result.reduce({}, &:merge).each_with_object({}) do |(social_name, values), acc|
      acc[social_name] = values.map { |value| value.dig(content_accessor(social_name)) }
    end

    result[:errors] = @errors unless @errors.empty?
    result
  end

  # we actualy need a default case but its not really real world code so :)
  def content_accessor(origin)
    case origin
    in :facebook
      'status'
    in :twitter
      'tweet'
    end
  end
end
